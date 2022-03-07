class scoreboard;
   
  //creating mailbox handle
  mailbox mon2scb;
  mailbox gen2scb;

  event mon_scb;
  //test pass fail status
  int pass,fail;
  //used to count the number of transactions
  int no_transactions;
  int trans_count;
  int j; 
  
  //array to use as local memory
  logic [7:0] mem[*];
  logic [`DW-1:0] temp_word; //-1
  
  //constructor
  function new( mailbox mon2scb);
    //getting the mailbox handles from  environment 
    this.mon2scb = mon2scb;
 //   this.vif = vif;
//     foreach(mem[i]) mem[i] = i;
//     for(j=0;j<1024;j=j+1) 
//       mem[j]=j;
  endfunction
  
  //stores wdata and compare rdata with stored data

  task main;
    forever begin
    transaction trans,trans_gen;
      mon2scb.get(trans);
//       $display($time," SCB:: Transaction : %p",trans);
      if(trans.error == 1)
        $error("Error :  Error signal is high!");
      
      if(!trans.hwrite && (trans.htrans==`H_NONSEQ || trans.htrans==`H_SEQ)) begin
        
        if(mem.exists(trans.haddr)) begin
        case (trans.hsize)
          `H_SIZE_32: begin //W
//             $display("word read");
            temp_word[31:0]={mem[trans.haddr+3],mem[trans.haddr+2],mem[trans.haddr+1],mem[trans.haddr]};
            if(temp_word[31:0] == trans.hrdata) begin
              $display("\t[SCB-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[31:0],trans.hrdata);
              pass++;
            end
            else begin
              $error("\t[SCB-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[31:0],trans.hrdata[31:0]);
              fail++;
            end
          end
           `H_SIZE_16: begin //HW
//              $display("HW read");
             case(trans.haddr[1])
                0: begin
                  temp_word[15:0] = {mem[trans.haddr+1],mem[trans.haddr]} ;
                  if(temp_word[15:0] == trans.hrdata[15:0]) begin
                    $display("\t[SCB-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[15:0],trans.hrdata[15:0]);
                    pass++;
                  end
                  else begin
                    $error("\t[SCB-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[15:0],trans.hrdata[15:0]);
                    fail++;
                  end
                end
                1: begin
                  temp_word[31:16] = {mem[trans.haddr+1],mem[trans.haddr]} ;
                  if(temp_word[31:16] == trans.hrdata[31:16]) begin
                    $display("\t[SCB-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[31:16],trans.hrdata[31:16]);
                    pass++;
                  end
                  else begin
                    $error("\t[SCB-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[31:16],trans.hrdata[31:16]);
                    fail++;
                  end
                end
              endcase
           end
            `H_SIZE_8: begin //Byte
//               $display("Byte read");
              case(trans.haddr[1:0])
                3: begin
                  temp_word[31:24] = mem[trans.haddr] ;
                  if(temp_word[31:24] == trans.hrdata[31:24]) begin
                    $display("\t[SCB-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[31:24],trans.hrdata[31:24]);
                    pass++;
                  end
                  else begin
                    $error("\t[SCB-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[31:24],trans.hrdata[31:24]);
                    fail++;
                  end
                  end
                2: begin
                  temp_word[23:16] = mem[trans.haddr] ;
                  if(temp_word[23:16] == trans.hrdata[23:16]) begin
                    $display("\t[SCB-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[23:16],trans.hrdata[23:16]);
                    pass++;
                  end
                  else begin
                    $error("\t[SCB-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[23:16],trans.hrdata[23:16]);
                    fail++;
                  end
                  end
                1: begin
                  temp_word[15:8] = mem[trans.haddr] ;
                  if(temp_word[15:8] == trans.hrdata[15:8]) begin
                    $display("\t[SCB-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[15:8],trans.hrdata[15:8]);
                    pass++;
                  end
                  else begin
                    $error("\t[SCB-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[15:8],trans.hrdata[15:8]);
                    fail++;
                  end
                  end
                0: begin
                  temp_word[7:0] = mem[trans.haddr] ;
                  if(temp_word[7:0] == trans.hrdata[7:0]) begin
                    $display("\t[SCB-PASS] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[7:0],trans.hrdata[7:0]);
                    pass++;
                  end
                  else begin
                    $error("\t[SCB-FAIL] Addr = %0h,\n \t   Data :: Expected = %0h Actual = %0h",trans.haddr,temp_word[7:0],trans.hrdata[7:0]);
                    fail++;
                  end
                  end
              endcase
            end
          endcase
      end
      end
      else if(trans.hwrite && (trans.htrans==`H_NONSEQ || trans.htrans==`H_SEQ)) begin
        
        case (trans.hsize)
            `H_SIZE_32: {mem[trans.haddr+3],mem[trans.haddr+2],mem[trans.haddr+1],mem[trans.haddr]} = trans.hwdata;
            `H_SIZE_16: 
              case(trans.haddr[1])
                0: {mem[trans.haddr+1],mem[trans.haddr]} = trans.hwdata[15:0];
                1: {mem[trans.haddr+1],mem[trans.haddr]} = trans.hwdata[31:16];
              endcase
            `H_SIZE_8:
              case(trans.haddr[1:0])
                0:mem[trans.haddr]= trans.hwdata[7:0]; 
                1:mem[trans.haddr]= trans.hwdata[15:8];
                2:mem[trans.haddr]= trans.hwdata[23:16];
                3:mem[trans.haddr]= trans.hwdata[31:24];
              endcase
          endcase
      end
      trans_count++;
    end
  endtask
   
endclass