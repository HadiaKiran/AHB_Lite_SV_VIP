//Interface groups the design signals, specifies the direction (Modport) and Synchronize the signals(Clocking Block)

interface dut_if(input logic hclk, hresetn);

    // Add design signals here
    logic  hsel;
    logic  hwrite;
    logic [`AW -1:0] haddr;
    logic [`DW -1:0] hwdata;
    logic [`DW -1:0] hrdata;
    logic [2:0] hsize;
    logic [2:0] hburst;
    logic [3:0] hprot;
    logic [1:0] htrans;
    logic  hmastlock;
    logic  hready;
    logic [`RW-1: 0]hresp;
    logic  error;
    
    //Driver/ Master Clocking block
  	clocking cb_drv  @(posedge hclk);
//     default input #1 output #1;
      output hsel;
      output haddr;
      output hwdata;
      output hwrite;
      output hsize;
      output hburst;
      output error;
      output hprot;
      output htrans;
      output hmastlock;
      //input of cb_drv _is o/p of ahb_slave dut. 
      input  hready;
      input  hresp;
      input  hrdata;
      
    endclocking
    
    //For sampling DUT i/o signals via interface.
  	clocking cb_mon  @(posedge hclk);
//     default input #1 output #1;
      input  hsel;
      input  haddr;
      input  hwdata;
      input  hwrite;
      input  hsize;
      input  hburst;
      input  hprot;
      input  htrans;
      input  hmastlock;
      input  hready;
      input  hresp;
      input  hrdata;
      input  hresetn;
      input  error;
      
    endclocking
  
    //Add modports here
  modport driver (clocking cb_drv,input hclk,hresetn);
  modport monitor (clocking cb_mon,input hclk,hresetn);
      
endinterface
