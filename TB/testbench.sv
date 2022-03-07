//Top most file which connets DUT, interface and the test
`include "amba_ahb_defines.v"
`include "interface.sv"
`include "test.sv"

//----------------------------------------------------------------

module testbench_top;
  
  //declare clock and reset signal
  bit clk, rst;
  
  //reset generation
  initial begin
  rst <= 0;
  clk <= 0;
  #5 rst <= 1;            
  end
  
  //clock generation
  always #5 clk = ~clk;


  //interface instance, inorder to connect DUT and testcase
  dut_if intf(clk,rst);

  //testcase instance, interface handle is passed to test as an argument
  test tst(intf);
  
  //DUT instance, interface signals are connected to the DUT ports
   amba_ahb_slave ahb_slave1 (.hclk (clk),
                        .hresetn(rst),
                        .hsel(intf.hsel),
                        .haddr(intf.haddr),
                        .htrans(intf.htrans),
                        .hwrite(intf.hwrite),
                        .hsize(intf.hsize),
                        .hburst(intf.hburst),
                        .hprot(intf.hprot),
                        .hwdata(intf.hwdata),
                        .hrdata(intf.hrdata),
                        .hready(intf.hready),
                        .hresp(intf.hresp),
                        .error(intf.error));
   initial begin 
    $dumpfile("dump.vcd"); $dumpvars;
    end
//endmodule

//functional Coverage evaluation.

//  covergroup cg_bursts @(posedge clk);
//  //   option.per_instance = 1;

//     coverpoint intf.hburst {
//       bins SINGLE   = {0};
//       bins INCR     = {1};
//       bins WRAP4    = {2};
//       bins INCR4    = {3};
//       bins WRAP8    = {4};
//       bins INCR8    = {5};
//       bins WRAP16   = {6};
//       bins INCR16   = {7};
//     }
//   endgroup

//   covergroup cg_sizes @(posedge clk);
//     coverpoint intf.hsize {
//       bins Byte              = {0};
//       bins Halfword          = {1};
//       bins Word              = {2};
//     }
//   endgroup
  
//   covergroup cg_trans @(posedge clk);                    
//     option.per_instance = 1;

//     coverpoint intf.htrans {
//       bins trans_idle_idle   = (0 => 0);
//       bins trans_idle_busy   = (0 => 1);
//       bins trans_busy_nonseq = (1 => 2);
//       bins trans_nonseq_seq  = (2 => 3);
//       bins trans_nonseq_busy = (2 => 1);
//       bins trans_nonseq_idle = (2 => 0);
//       bins trans_nonseq_nonseq  = (2 => 2);
//     }
//   endgroup

  covergroup cg_trans @(posedge clk);                    
    option.per_instance = 1;

    coverpoint intf.htrans {
//       bins trans_idle   = {0};
//       bins trans_busy   = {1};
      bins trans_nonseq = {2};
      bins trans_seq    = {3};
    }
  endgroup
  
//     covergroup cross_cg_burstWITHsizes @(posedge clk);
//     //option.per_instance = 1;
//     coverpoint intf.hburst {
//       bins SINGLE   = {0};
//       bins INCR     = {1};
//       bins WRAP4    = {2};
//       bins INCR4    = {3};
//       bins WRAP8    = {4};
//       bins INCR8    = {5};
//       bins WRAP16   = {6};
//       bins INCR16   = {7};
//     }
//      coverpoint intf.hsize {
//       bins Byte              = {0};
//       bins Halfword          = {1};
//       bins Word              = {2};
//     }
//     cross intf.hburst, intf.hsize ;
//   endgroup
  
  covergroup cg_address @(posedge clk);                   
    //option.per_instance = 1;
    
      coverpoint intf.haddr {
        bins zero[4] = {[0:8]};
        bins low[4]  = {[8:16]};
        bins med[4]  = {[16:64]};
        bins high[4] = {[64:127]};
        bins others  = default;
    }
  endgroup
      
 // cg_bursts covbursts;
 // cg_sizes covsizes;
 // cross_cg_burstWITHsizes cg_cross;
  cg_address covaddr;
  cg_trans covtrans;

  initial begin
  // covbursts   = new();
  // covsizes    = new();
  // cg_cross    = new();
   covaddr     = new();
   covtrans    = new();
   end

  endmodule



