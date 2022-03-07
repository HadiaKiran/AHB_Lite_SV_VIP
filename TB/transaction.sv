//Fields required to generate the stimulus are declared in the transaction class
`include "amba_ahb_defines.v"

class transaction;
  
  typedef enum bit [1:0] {IDLE,BUSY,NONSEQ,SEQ} HTRANS;
  typedef enum bit [2:0] {BYTE,HALFWORD,WORD,BITS64,BITS128,BITS256,BITS512,BITS1024} HSIZE;
  typedef enum bit [2:0] {SINGLE,INCR,WRAP4,INCR4,WRAP8,INCR8,WRAP16,INCR16} HBURST;
  
  rand HTRANS [1:0]   htrans;
  rand HSIZE  [2:0]   hsize;
  rand HBURST [2:0]   hburst;
  rand bit          hsel;     // Slave select
  rand bit [`DW-1:0]haddr;
  rand bit [`DW-1:0]hwdata;
  rand bit    [3:0] hprot;
  rand bit          hwrite;
  logic    [`DW-1:0]hrdata;
    bit  error;                   
  //slave out signals.
  bit      [`RW-1:0]hresp;
  bit hready;
  rand int unsigned burst_incr;   
  
//   constraint c_burst {hburst ==3'b000;}
// //htrans_
//   constraint c_trmodes { htrans dist{2'b00:=1, 2'b01:=1, 2'b10:=8 };}
 
  constraint c_addr
  {       //   001/010_halfword/word
      hsize == `H_SIZE_16 -> haddr[0]   == '0;
      hsize == `H_SIZE_32 -> haddr[1:0] == '0;
    haddr inside{[0:127]};
      solve hsize before haddr;
    }
 
  constraint c_prot { hprot == 'b1;}
  
  //constraint c_hsize { hsize inside {`H_SIZE_8};}      //chk for word only.
  constraint c_hsize { hsize inside {`H_SIZE_8};};       //for all 3 sizes.

  constraint c_sel { hsel == '1;}
  
  // Single burst.
  constraint c_burst {hburst == 3'b001;}  //set to incr.
  //constraint c_burst { hburst inside {[0:7]} ; }

  //bursts
  constraint c_burst_cases {
    if(hburst==INCR) { burst_incr == 1;}  //hburst=001(Incrementing burst of undefined length)
      if(hburst==INCR4 || hburst==WRAP4)  { burst_incr == 4;}           //011 or 010
        if(hburst==INCR8 || hburst==WRAP8)  { burst_incr == 8;}           //101 or 100
          if(hburst==INCR16|| hburst==WRAP16) { burst_incr == 16;}          //111 or 110
        }
  
  //print_trans method to print the transaction item values  
  function void print_trans(string comp = " ");
$display($time, " %s :: hsel=%0x, haddr=%0x, htrans=%0x, hwrite=%0x, hsize=%0x, hburst=%0x, hprot=%0b, hwdata=%0x, hrdata=%0x, hready=%0x, hresp=%0x, error=%0x\n",comp, hsel, haddr, htrans, hwrite, hsize, hburst, hprot, hwdata, hrdata, hready, hresp, error);
  endfunction
 
   
endclass