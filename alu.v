`timescale 1ns / 1ps

module alu #(parameter n=8)(A,B,CIN,CLK,RST,CMD,CE,MODE,INP_VALID,Cout,Oflow,result,g,l,e,error);
localparam RW = $clog2(n);
input [n-1:0] A,B;
input CLK,RST,CE,MODE,CIN;
 input [1:0]INP_VALID;
 input [3:0] CMD;
 output reg [(2*n)-1:0] result;
output reg Cout ;
output reg Oflow;
output reg g;
output reg e ;
output reg l ;
output reg error ;
   reg [n-1:0] OPA,OPB;
   reg [(2*n)-1:0] RES ;
   reg COUT ;
   reg OFLOW;
   reg G;
   reg E ;
   reg L ;
  reg ERR ;
reg [2:0]cnt=0;
reg signed [(2*n)-1:0]sres;
  reg signed [n-1:0] SOPA, SOPB;
always@(posedge CLK)
begin
 if(RST)
    begin
        result<=0;
        g<=0;
        l<=0;
        e<=0;
        error<=0;
        Cout<=0;
        Oflow<=0;
        cnt<=0;
     end
   else
    begin
        if(CE)
         begin
           if (MODE && (CMD == 4'd9 || CMD == 4'd10))
            begin
              if (cnt == 0) begin
                OPA <= A;
                OPB <= B;
                SOPA <= A;
                SOPB <= B;
                cnt <= 1;
                end
               else if (cnt == 1) begin
                  cnt <= 2;
                 end
               else if (cnt == 2) 
                begin
                        result <= RES;
                        Cout   <= COUT;
                        Oflow  <= OFLOW;
                        g <= G; l <= L; e <= E;
                        error <= ERR;
                        cnt<=0;
                 end
              end 
           else 
             begin
                 OPA<=A;
                 OPB<=B;
                 SOPA<=A;
                 SOPB<=B;
                result<=RES;
                g<=G;
                l<=L;
                e<=E;
                error<=ERR;
                Cout<=COUT;
                Oflow<=OFLOW;
                cnt<=0;
            end
       end
       end
  end 
 
    always@(*)
      begin
          G=0;
          L=0;
          E=0;
          COUT=0;
          OFLOW=0;
          RES=0;
          ERR=0;
		   if(MODE)
		      begin
			   case(CMD)
			    4'd0:
			      if(INP_VALID==2'b11)
			       begin
			         RES=OPA+OPB;  
			         COUT=RES[n];
			       end
			      else
			        ERR=1;
			     4'd1:
			       if(INP_VALID==2'b11)
			       begin
			         RES=OPA-OPB;  
			         OFLOW=OPA<OPB;
			       end
			       else
			        ERR=1;
			     4'd2:
			      if(INP_VALID==2'b11)
			        begin
			         RES=OPA+OPB+CIN;  
			         COUT=RES[n];
			        end
			        else
			        ERR=1;
			     4'd3:
			      if(INP_VALID==2'b11)
			         begin
			         RES=OPA-OPB-CIN;  
			         OFLOW=OPA<(OPB+CIN);
			         end
			        else
			        ERR=1;
			     4'd4:
			      if((INP_VALID==2'b11) || (INP_VALID==2'b01))
			        begin
			         RES[n-1:0]=OPA+1;  
			         end
			        else
			        ERR=1;
			     4'd5:
			        if((INP_VALID==2'b11) || (INP_VALID==2'b01))
			         begin
			         RES[n-1:0]=OPA-1;  
			         end
			        else
			        ERR=1;
			     4'd6:
			       if((INP_VALID==2'b11) || (INP_VALID==2'b10))
			         begin
			         RES[n-1:0]=OPB+1;  
			         end
			       else
			        ERR=1;
			     4'd7:
			       if((INP_VALID==2'b11) || (INP_VALID==2'b10))
			         begin
			         RES[n-1:0]=OPB-1; 
			          end
			        else
			        ERR=1;
			     4'd8:
			      begin
			      RES=0;
			       if(INP_VALID==2'b11)
			        begin
                      if(OPA==OPB)
                       begin
                       E=1'b1;
                       G=1'b0; 
                       L=1'b0;
                       end
                      else if(OPA>OPB)
                       begin
                        E=1'b0;
                        G=1'b1;
                        L=1'b0;
                        end
                       else
                        begin
                        E=1'b0;
                        G=1'b0;
                        L=1'b1;
                        end
                     end
                   else
                     ERR=1;
                 end
			     4'd9:
			     begin
			      if(INP_VALID==2'b11)
			       begin
			         RES=(OPA+1)*(OPB+1);
			       end
			      else
			        ERR=1;
			     end
			     4'd10:
			      begin
			       if(INP_VALID==2'b11)
			        begin
			         RES=(OPA<<1)*(OPB);
			        end
			       else
			        ERR=1;
			      end
			     4'd11:
			      begin
			       if(INP_VALID==2'b11)
			        begin
			           sres=SOPA+SOPB;
			           RES=sres;
			          {G,L,E}={SOPA > SOPB, SOPA < SOPB, SOPA == SOPB};
			          OFLOW=(SOPA[n-1]==SOPB[n-1])&&(SOPA[n-1]!=RES[n-1]);
			         end
			        else
			          ERR=1;
			       end
			      4'd12:
			         begin
			           if(INP_VALID==2'b11)
			            begin
			             sres=SOPA-SOPB;
			           RES=sres;
			              {G,L,E}={SOPA > SOPB, SOPA < SOPB, SOPA == SOPB};
			             OFLOW=(SOPA[n-1]!=SOPB[n-1])&&(SOPA[n-1]!=RES[n-1]);
			            end
			           else
			             ERR=1;
			          end
			     endcase
			    end
			   else
			    begin
			       RES=0;
                   COUT=1'b0;
                   OFLOW=1'b0;
                   G=1'b0;
                   E=1'b0;
                   L=1'b0;
                   ERR=1'b0;
                  case(CMD)    
                     4'b0000: if(INP_VALID==2'b11)
                                  RES={1'b0,OPA&OPB};   
                               else
                                 ERR=1;  
                     4'b0001:if(INP_VALID==2'b11)
                                 RES={1'b0,~(OPA&OPB)};  
                             else
                               ERR=1;
                     4'b0010:if(INP_VALID==2'b11)
                                  RES={1'b0,OPA|OPB};  
                               else
                                 ERR=1;  
                     4'b0011:if(INP_VALID==2'b11)
                                  RES={1'b0,~(OPA|OPB)};  
                              else
                                ERR=1;
                     4'b0100:if(INP_VALID==2'b11)
                                RES={1'b0,OPA^OPB};   
                              else
                                ERR=1;  
                     4'b0101:if(INP_VALID==2'b11)
                              RES={1'b0,~(OPA^OPB)};  
                             else
                                ERR=1;
                     4'b0110:if(INP_VALID==2'b11 || INP_VALID==2'b01)
                                 RES={1'b0,~OPA}; 
                              else
                                 ERR=1;       
                     4'b0111:if(INP_VALID==2'b11 || INP_VALID==2'b10)
                                 RES={1'b0,~OPB};  
                             else
                                ERR=1;      
                     4'b1000:if(INP_VALID==2'b11 || INP_VALID==2'b01)
                                     RES={1'b0,OPA>>1}; 
                             else
                                ERR=1;     
                     4'b1001:if(INP_VALID==2'b11 || INP_VALID==2'b01)
                                 RES={1'b0,OPA<<1};      
                              else 
                                ERR=1;
                     4'b1010:if(INP_VALID==2'b11 || INP_VALID==2'b10)
                                  RES={1'b0,OPB>>1};      
                              else
                                  ERR=1;
                     4'b1011:if(INP_VALID==2'b11 || INP_VALID==2'b10)
                                  RES={1'b0,OPB<<1};      
                             else
                                 ERR=1;
                     4'b1100:                       
                         begin 
                         if(INP_VALID==2'b11 || ~|OPB[n-1:RW])
                              RES = (OPA << OPB[RW-1:0] | OPA >> (n - OPB[RW-1:0])) & {n{1'b1}};
                            else
                              ERR=1;
                          end
                    4'b1101:                       
                         begin 
                         if(INP_VALID==2'b11 || ~|OPB[n-1:RW])
                               RES = (OPA >> OPB[RW-1:0] | OPA << (n - OPB[RW-1:0])) & {n{1'b1}};
                           else
                              ERR=1;
                         end
                  endcase
              end
           end
 endmodule
