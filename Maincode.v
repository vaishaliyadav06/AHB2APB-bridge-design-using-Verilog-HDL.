`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.02.2023 08:53:26
// Design Name: 
// Module Name: intern
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bridge_top(hclk,hresetn,hwrite,hready_in,htrans,hwdata,haddr,pr_data,penable,pwrite,hready_out,psel,hres,paddr,pwdata,hr_data);
input hclk,hresetn,hwrite,hready_in,haddr;
input [1:0]htrans;
input [31:0]hwdata,pr_data;
output penable,pwrite,hready_out;
output [2:0]psel;
output [1:0]hres;
output [31:0]paddr,pwdata,hr_data;
wire valid;
wire [31:0]haddr1,haddr2,hwdata1,hwdata2;
wire hwritereg;
wire [2:0]tempselx;
ahb_slave_interface ahbslave(haddr,hwdata,hwrite,hres,hr_data,htrans,hclk,hready_in,hresetn,haddr1,hwdata1,haddr2,hwdata2,hwritereg,valid,tempselx,pr_data);
apb_controller apbcontrol(haddr1,haddr2,hwdata1,hwdata2,hwrite,hwritereg,tempselx,valid,paddr,pwdata,psel,pwrite,penable,hclk,hresetn,htrans,hready_out);

endmodule

module ahb_slave_interface(haddr,hwdata,hwrite,hres,hr_data,htrans,hclk,hready_in,hresetn,haddr1,hwdata1,haddr2,hwdata2,hwritereg,valid,tempselx,pr_data);
input [31:0]haddr,hwdata,pr_data;
input [1:0]htrans;
input hready_in,hwrite;
input hclk,hresetn;
output reg valid,hwritereg;
output [31:0]hr_data;
output [1:0]hres;
output reg[2:0]tempselx;
output reg[31:0]haddr1,haddr2,hwdata1,hwdata2;
parameter idle=2'b00;
parameter busy=2'b01;
parameter nonseq=2'b10;
parameter seq=2'b10;
always @(posedge hclk)
begin
if(!hresetn)
begin
haddr1<=0;
haddr2<=0;
end
else
begin
haddr1<=haddr;
haddr2<=haddr1;
end
end
always @(posedge hclk)
begin
if(!hresetn)
begin
hwdata1<=0;
hwdata2<=0;
end
else
begin
hwdata1<=hwdata;
hwdata2<=hwdata1;
end
end
always @(posedge hclk)
begin
if(!hresetn)
begin
hwritereg<=0;
end
else
begin
hwritereg<=hwrite;
end
end
always @(*)
begin
valid=1'b0;
if(hready_in==1 && haddr>=32'h0000_0000 && haddr<32'h8c00_0000 && htrans==2'b10||htrans==2'b11)
valid=1;
else
valid=0;
end
always @(*)
begin
tempselx=3'b000;
if(haddr>=32'h0000_0000 && haddr<32'h8400_0000)
tempselx=3'b001;
if(haddr>=32'h8400_0000 && haddr<32'h8800_0000)
tempselx=3'b010;
if(haddr>=32'h8800_0000 && haddr<32'h8c00_0000)
tempselx=3'b000;
end
assign hr_data=pr_data;
assign hres=2'b0;
endmodule

module apb_controller(haddr1,haddr2,hwdata1,hwdata2,hwrite,hwritereg,tempselx,valid,paddr,pwdata,psel,pwrite,penable,hclk,hresetn,htrans,hready_out);
input [31:0]haddr1;
input [31:0]haddr2;
input [31:0]hwdata1;
input [31:0]hwdata2;
input [1:0]htrans;
input [2:0]tempselx;
input hclk,hresetn,valid,hwrite,hwritereg;
output reg[31:0]paddr,pwdata;
output reg[2:0]psel;
output reg pwrite,penable,hready_out;
reg [2:0]state,nx_state;
reg tmp;
parameter ST_idle=3'b000;
parameter ST_wwait=3'b001;
parameter ST_read=3'b010;
parameter ST_write=3'b011;
parameter ST_writep=3'b100;
parameter ST_renable=3'b101;
parameter ST_wenable=3'b110;
parameter ST_wenablep=3'b111;
always @(posedge hclk,negedge hresetn)
begin
if(~hresetn)
state<=ST_idle;
else
state<=nx_state;
end
always @(*)
begin
nx_state=ST_idle;
psel=0;
penable=0;
hready_out=0;
pwrite=0;
case(state)
ST_idle:begin
psel=0;
penable=0;
hready_out=1'b1;
if(~valid)
nx_state=ST_idle;
else if(valid&&hwrite)
nx_state=ST_wwait;
else
nx_state=ST_read;
end
ST_wwait:begin
hready_out=1'b1;
psel=0;
penable=0;
tmp=1;
if(~valid)
nx_state=ST_write;
else if(valid)
nx_state=ST_writep;
end
ST_read:begin
psel=tempselx;
penable=1'b0;
paddr=haddr1;
pwrite=1'b0;
hready_out=1'b0;
nx_state=ST_renable;
end
ST_write:begin
psel=tempselx;
paddr=haddr2;
pwrite=1'b1;
pwdata=hwdata1;
penable=1'b0;
if(~valid)
nx_state=ST_wenable;
else if(valid)
nx_state=ST_wenablep;
end
ST_write:begin
// if()
// paddr=haddr2;
// else
if(tmp==1)
psel=tempselx;
penable=1'b0;
pwrite=1'b1;
pwdata=hwdata1;
hready_out=1'b0;
nx_state=ST_wenablep;
end
ST_renable:begin
penable=1'b1;
psel=tempselx;
pwrite=1'b0;
hready_out=1'b1;
if(~valid)
nx_state=ST_idle;
else if(valid && ~hwrite)
nx_state=ST_wwait;
end
ST_wenable:begin
penable=1'b1;
psel=tempselx;
pwrite=1'b1;
hready_out=1'b1;
if(valid && ~hwrite)
nx_state=ST_read;
else if(~valid)
nx_state=ST_idle;
else if(valid && hwrite)
nx_state=ST_wwait;
end
ST_wenablep:begin
tmp=0;
psel=tempselx;
penable=1'b1;
pwrite=1'b1;
hready_out=1'b1;
if(~hwritereg)
nx_state=ST_read;
else if(~valid && hwritereg)
nx_state=ST_write;
else if(valid && hwritereg)
nx_state=ST_writep;
end
default:nx_state=ST_idle;
endcase
end
endmodule

module ahb_master(hclk,hresetn,hready_out,hr_data,haddr,hwdata,hwrite,hready_in,htrans);
input hclk,hresetn,hready_out;
input [31:0]hr_data;
output reg[31:0]haddr,hwdata;
output reg hwrite,hready_in,htrans;
reg [2:0]hburst;
reg [2:0]hsize;
task single_write();
begin
@(posedge hclk);
#1
begin
hwrite=1;
htrans=2'd2;
hsize=0;
hburst=0;
hready_in=1;
haddr=32'h8000_0001;
end
@(posedge hclk);
#1
begin
htrans=2'd0;
end
end
endtask
endmodule

module apb_interface(pwrite,psel,penable,paddr,pwdata,pwriteout,pselout,penableout,paddrout,pwdataout,pr_data);
input pwrite,penable;
input [2:0]psel;
input [31:0]pwdata,paddr;
output pwriteout,penableout;
output [2:0]pselout;
output [31:0]pwdataout,paddrout;
output reg[31:0]pr_data;
assign penableout=penable;
assign pselout=psel;
assign pwriteout=pwrite;
assign paddrout=paddr;
assign pwdataout=pwdata;
always @(*)
begin
if(~pwrite && penable)
pr_data=($random)%256;
else
pr_data=0;
end
endmodule
