//Gets the packet from generator and drive the transaction packet items into interface (interface is connected to DUT, so the items driven into interface signal will get driven in to DUT) 
`define DRV vintf.driver.cb_drv

class driver;
  
  int num_trans;
  transaction trans;
  //creating virtual interface handle
  virtual dut_if vintf;
  
  //creating mailbox handle
  mailbox gen2drv;
  
  //constructor
  function new(virtual dut_if vintf,mailbox gen2drv);
    this.vintf = vintf;
    this.gen2drv = gen2drv;
  endfunction
  
  //Reset task, Reset the Interface signals to default/initial values
  task reset;
    wait(!vintf.hresetn);
    $display("__________DRIVER: Reset begin__________");
        `DRV.haddr       <= '0;
        `DRV.hburst      <= '0;
        `DRV.hmastlock   <= '0;
        `DRV.hprot       <= 4'b0001;     
        `DRV.hsize       <= 3'b010;
        `DRV.htrans      <= '0;
        `DRV.hwdata      <= '0;
        `DRV.hwrite      <= '0;
        `DRV.hsel        <= 1'b1; 
    wait(vintf.hresetn);
    $display("__________DRIVER: Reset end__________");
  endtask
  
  //drive packets
  task drive();
    transaction trans;
    gen2drv.get(trans);
    
      `DRV.hsel   <= trans.hsel;
      `DRV.haddr  <= trans.haddr;
      `DRV.htrans <= trans.htrans;
      `DRV.hwrite <= trans.hwrite;
      `DRV.hsize  <= trans.hsize;
      `DRV.hburst <= trans.hburst;
      `DRV.hprot  <= trans.hprot;
    $display("DRV:: trans.haddrr= %0h",trans.haddr);

    
    @(`DRV);
      `DRV.hwdata <= trans.hwdata;
    
    $display("%d:\t-----------------------------------------",num_trans);
    $display($time," DRIVER:: Transaction : %p",trans);
    num_trans++;
 
  endtask 
  
 //main methods
 task main;
        wait(vintf.hresetn);    
        begin
        forever
        drive();
        end
    
 endtask
        
endclass 
