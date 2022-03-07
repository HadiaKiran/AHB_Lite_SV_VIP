//Samples the interface signals, captures into transaction packet and sends the packet to scoreboard.
`define MON vintf.monitor.cb_mon

class monitor;
  //creating virtual interface handle
  virtual dut_if vintf;
  
  //creating mailbox handle
  mailbox mon2scb;
  
  //constructor
  function new(virtual dut_if vintf,mailbox mon2scb);
    this.vintf = vintf;
    this.mon2scb = mon2scb;
  endfunction
  
  //monitor class samples the interface signals. 
  task main; 
    @(`MON);                                  
    forever begin
      
      transaction trans;
      trans = new();
        trans.hsel   = `MON.hsel;
        trans.haddr  = `MON.haddr;
        trans.htrans = `MON.htrans;
        trans.hwrite = `MON.hwrite;
        trans.hsize  = `MON.hsize;
        trans.hburst = `MON.hburst;
        trans.hprot  = `MON.hprot;
        trans.error  = `MON.error;
      @(`MON);
        trans.hwdata = `MON.hwdata;
	 	trans.hrdata = `MON.hrdata;
      	trans.hready = `MON.hready;
      	trans.hresp  = `MON.hresp;     
        mon2scb.put(trans);
      $display($time," MONITOR:: Transaction : %p",trans);
    end
  endtask

endclass
