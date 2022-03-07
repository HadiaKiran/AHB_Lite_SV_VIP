//A container class that contains Mailbox, Generator, Driver, Monitor and Scoreboard
//Connects all the components of the verification environment
`include "transaction.sv"
`include "generator.sv"
`include "driver.sv"
`include "monitor.sv"
`include "scoreboard.sv"

class env;
  
  //handles of all components
  generator GEN;
  driver DRV;
  monitor MON;
  scoreboard SCB;
  
  //mailbox handles
  mailbox gen2drv;
  mailbox mon2scb;
  
  //declare an event
  event tr_flag1;

  //virtual interface handle
  virtual dut_if vintf;
  
  //constructor
  function new(virtual interface dut_if vintf);
    this.vintf = vintf;
    gen2drv = new();
    mon2scb = new();
    GEN = new(gen2drv,tr_flag1);
    DRV = new(vintf,gen2drv);
    MON = new(vintf,mon2scb);
    SCB = new(mon2scb);
  endfunction
  
  
  //pre_test methods
  task pre_test();
    DRV.reset();
    $display("pre_test done in ENV");
  endtask
  
  //test methods
  task test();
    fork
//  GEN.single_burst();
    GEN.incr_burst();
//  GEN.n_incr_wrap();
    DRV.main();
    MON.main();
    SCB.main();
    join_any
  endtask
  
//post_test methods
    task post_test();
//waiting for an event to be triggered after completion of random packets generation in GEN!
      wait(tr_flag1.triggered); 
      wait(GEN.count == DRV.num_trans); 
      wait(GEN.count == SCB.trans_count);
    endtask
    
//run methods
  task run();
    pre_test();
    test();
    post_test();
    
    $display(" Number of Passed Tests =\t",SCB.pass);
    
    $display(" Number of Failed Tests =\t",SCB.fail);

    $finish;
  endtask
  
endclass






