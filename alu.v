module Eight_bit_ALU_rtl_design(OPA,OPB,CIN,CLK,RST,CMD,CE,MODE,INP_VALID,COUT,OFLOW,RES,G,E,L,ERR);


  input [7:0] OPA,OPB;
  input CLK,RST,CE,MODE,CIN,INP_VALID;
  input [3:0] CMD;
  output reg [8:0] RES = 9'bz;
  output reg COUT = 1'bz;
  output reg OFLOW = 1'bz;
  output reg G = 1'bz;
  output reg E = 1'bz;
  output reg L = 1'bz;
  output reg ERR = 1'bz;


  reg [7:0] OPA_1, OPB_1;

    always@(posedge CLK or posedge RST)
      begin
       if(RST)                  
        begin
            RES=9'b0;
            COUT=1'b0;
            OFLOW=1'b0;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b0;
          end
        else
         if(!CE)               
          begin
            RES=RES;
            COUT=COUT;
            OFLOW=OFLOW;
            G=1'b0;
            E=1'b0;
            L=1'b0;
            ERR=1'b0;
          end

         else if(MODE)        
         begin
           RES=9'bzzzzzzzzz;
           COUT=1'bz;
           OFLOW=1'bz;
           G=1'bz;
           E=1'bz;
           L=1'bz;
           ERR=1'bz;
          case(CMD)             
           4'b0000:             
            begin             
              RES=OPA+OPB;
              COUT=RES[8]?1:0;
            end
	   4'b0001:             
            begin
             OFLOW=(OPA<OPB)?1:0;
             RES=OPA-OPB;
            end
           4'b0010:             
            begin
             RES=OPA+OPB+CIN;
             COUT=RES[8]?1:0;
            end
           4'b0011:             
           begin
            OFLOW=(OPA<OPB)?1:0;
            RES=OPA-OPB-CIN;
           end
           4'b0100:RES=OPA+1;   
           4'b0101:RES=OPA-1;   
           4'b0110:RES=OPB+1;    
           4'b0111:RES=OPB-1;    
           4'b1000:              
           begin
            RES=9'bzzzzzzzzz;
            if(OPA==OPB)
             begin
               E=1'b1;
               G=1'bz;
               L=1'bz;
             end
            else if(OPA>OPB)
             begin
               E=1'bz;
               G=1'b1;
               L=1'bz;
             end
            else 
             begin
               E=1'bz;
               G=1'bz;
               L=1'b1;
             end
           end
           default:
            begin
            RES=9'bzzzzzzzzz;
            COUT=1'bz;
            OFLOW=1'bz;
            G=1'bz;
            E=1'bz;
            L=1'bz;
            ERR=1'bz;
           end
          endcase
         end

        else          
        begin 
           RES=9'bzzzzzzzzz;
           COUT=1'bz;
           OFLOW=1'bz;
           G=1'bz;
           E=1'bz;
           L=1'bz;
           ERR=1'bz;
           case(CMD)    
             4'b0000:RES={1'b0,OPA&OPB};     
             4'b0001:RES={1'b0,~(OPA&OPB)};  
             4'b0010:RES={1'b0,OPA|OPB};     
             4'b0011:RES={1'b0,~(OPA|OPB)}; 
             4'b0100:RES={1'b0,OPA^OPB};    
             4'b0101:RES={1'b0,~(OPA^OPB)};  
             4'b0110:RES={1'b0,~OPA};        
             4'b0111:RES={1'b0,~OPB};        
             4'b1000:RES={1'b0,OPA>>1};      
             4'b1001:RES={1'b0,OPA<<1};      
             4'b1010:RES={1'b0,OPB>>1};      
             4'b1011:RES={1'b0,OPB<<1};      
             4'b1100:                        
             begin 
               if(OPB[0])
                 OPA_1 = {OPA[6:0], OPA[7]};
               else
                 OPA_1 = OPA;

               if(OPB[1])
                 OPB_1 =  {OPA_1[5:0], OPA_1[7:6]}; 
               else
                 OPB_1= OPA_1;

               if(OPB[2])
                 RES =  {OPB_1[3:0], OPB_1[7:4]} ;
               else
                 RES = OPB_1;

               if(OPB[4] | OPB[5] | OPB[6] | OPB[7])
                 ERR=1'b1;
             end
             4'b1101:                        
             begin
               if(OPB[0])
                 OPA_1 = {OPA[0], OPA[7:1]};
               else
                 OPA_1 = OPA;
               if(OPB[1])
                 OPB_1 =  {OPA_1[1:0], OPA_1[7:2]}; 
               else
                 OPB_1= OPA_1;
               if(OPB[2])
                 RES =  {OPB_1[3:0], OPB_1[7:4]} ;
               else
                 RES = OPB_1;
               if(OPB[4] | OPB[5] | OPB[6] | OPB[7])
                 ERR=1'b1;
             end
             default:    
               begin
               RES=9'bzzzzzzzzz;
               COUT=1'bz;
               OFLOW=1'bz;
               G=1'bz;
               E=1'bz;
               L=1'bz;
               ERR=1'bz;
               end
          endcase
     end
    end
   end
endmodule
