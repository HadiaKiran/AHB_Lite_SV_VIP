`include "amba_ahb_defines.v"

class generator;
  
  //declaring transaction class 
  rand transaction trans;
  
  //# random tr items.
  int  count;
  int num_trans;
  mailbox gen2drv;
  event tr_flag;
  
  int array[*];
  
  logic [`AW-1:0] addr;
  logic [2:0] size;              // hsize_ byte/HW/W
  logic [`AW-1:0] start_addr;
  logic [`AW-1:0] next_addr;
  logic [2:0]  burst;            //hburst.
  bit          wrap_flag=0;           //1 when address wrapped.
  bit          wrap_incr=0;         //increment for wrapping case.
  byte unsigned beats;      //burst type = #beats;   burst_length and 1/4/8/16 len_burst_incr
 
    int i=1;
    int j=0;
    int k=0;
  
  //class constructor
  function new(mailbox gen2drv,event tr_flag);
    //getting the mailbox handle from env, in order to share the transaction packet between the generator and driver, the same mailbox is shared between both.
    this.gen2drv    = gen2drv;
    this.tr_flag    = tr_flag;  
  endfunction
  
//GEN: Generates randomized transaction packets and put them in the mailbox for driver to get.

 task single_burst();
    $display("\t Generator class/comp: for random transaction packets generation ");
  
    repeat(count) begin
    trans = new();     
      if( !trans.randomize() ) 
      $fatal(" trans randomization failed ");  
      
      gen2drv.put(trans);
      $display($time, " Generator: Transaction item# %d is put into mailbox : %p",num_trans, trans);
    num_trans++;
    end
    // event triggered after N/count -num of random packets generation.
    -> tr_flag; 
  endtask
  
//incr burst case (undefined length)
   task incr_burst();
    
    repeat( count ) begin 
      trans = new();     
      if( !trans.randomize() ) 
       $fatal("Gen: trans randomization failed");
      
      trans.hburst = 1;   //INCR
      trans.hwrite = 1;   //write
      start_addr = trans.haddr;
      array[0]   = trans.haddr;
      beats      = trans.burst_incr;   //1
      size       = trans.hsize;
      
      if(i==1)
        begin
        trans.haddr = start_addr;
        trans.htrans =2;   //nonseq
        end
        else begin
        trans.htrans =3;   //seq
        trans.haddr = next_addr;
          array[0]  = next_addr;
        end
       gen2drv.put(trans);
       next_addr = start_addr + i * (2 ** trans.hsize);
       i++;
  
       //read
      repeat( beats ) begin
       trans = new();     
         if( !trans.randomize() ) 
         $fatal("Gen: Randomization failed");
       trans.hburst = 1;   //INCR
       trans.htrans = 3;   //seq
       trans.hwrite = 0;   //read
       trans.haddr  = array[0];    //incremental read after every write, start_addr to next_addr->next_addr so on.
       size         = trans.hsize;
       gen2drv.put(trans);
       end
      
    end               //repeat (count) end.
    -> tr_flag;
  endtask
  
  //task for all other incr and wrap cases.
  
  task n_incr_wrap();
    
    repeat( count ) begin
      
      trans = new();     
      if( !trans.randomize() ) 
       $fatal("Gen: Randomization failed");
      trans.htrans = 2;  //nonseq
      trans.hwrite = 1; 
      
      if(i!=1 && !wrap_flag)
        begin
        trans.haddr = next_addr + (2 ** trans.hsize);  
        end
      else if(i!=1 && wrap_flag)
        trans.haddr = next_addr;
      
      array[k] = trans.haddr;
      k = k+1;
      gen2drv.put(trans);
      
      if(i==1)
      start_addr = trans.haddr;
      burst      = trans.hburst;
      size       = trans.hsize;
      beats      = trans.burst_incr;
        
      repeat(beats -1) begin                    //for incr4 : beats=4
        trans = new();     
        if( !trans.randomize() ) 
          $fatal("Gen: Randomization failed");
        
         //incr: 3 5 7/ wrap: 2 4 6
        
        if ( trans.hburst == 3 || trans.hburst == 5 || trans.hburst == 7 ) begin
          if (i >= beats)                    //4 >= 4 for incr=3, true onwards
            next_addr = start_addr + i * (2 ** trans.hsize) + (2 ** trans.hsize);
          else
            next_addr = start_addr + i * (2 ** trans.hsize);
          
        end
        
        
        if( trans.hburst == 2 || trans.hburst == 4 || trans.hburst == 6 ) begin
            byte n_burst;
            byte wrap_limit;
            wrap_incr = 1;
          
          case(trans.hburst)
                2: n_burst=4;
                4: n_burst=8;
                6: n_burst=16;
          endcase
          
            wrap_limit = n_burst * (2 ** trans.hsize);
            next_addr=start_addr + i * (2 ** trans.hsize);
          
          if( ((next_addr % wrap_limit)==0) && ( next_addr != start_addr) )
              begin
              next_addr=next_addr - wrap_limit; 
              wrap_flag=1;
              end
             else wrap_flag=0;
        end                              //if of wrap cases ended.
        
        array[k]     = next_addr;
        trans.hburst = burst; 
        trans.htrans = 3;
        trans.hwrite = 1; 
        trans.haddr  = next_addr; 
        trans.hsize  = size; 
        gen2drv.put(trans);
         i = i+1;
         k = k+1;
        if(i == beats && wrap_incr)
        i=1;

      end
      
       //read sequence
      repeat(beats) begin
         trans = new();     
         if( !trans.randomize() ) 
          $fatal("Gen: Randomization failed");
         trans.hburst = burst;
         trans.htrans = 3;
         trans.hwrite = 0; 
         trans.haddr = array[j]; 
         trans.hsize = size;
         gen2drv.put(trans);
         j = j+1;
        end
      
    end
    -> tr_flag;
  endtask
  
endclass

//formatting element %p_for printing packed struct.
