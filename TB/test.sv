//A program block that creates the environment and initiate the stimulus
//PB_ similar to module just region of exec is diff to avoid race.
`include "env.sv"

program test(interface intf);   
  
  //declare environment handle
  env ENV;
  
  initial begin
    //create environment
    ENV = new(intf);
    ENV.GEN.count=500;
    //initiate the stimulus by calling run of env
    ENV.run();

  end

endprogram
