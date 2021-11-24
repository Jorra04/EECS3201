`timescale 1ns / 1ns 
module full_adderV_tb; 

    wire    t_out_sum, t_out_carry; 
    reg     t_a, t_b, t_c; 
    
    full_adderV my_full_adder(.a(t_a), .b(t_b), .c(t_c), .fsum(t_out_sum), .fcarry_out(t_out_carry)); 
    
    initial begin
        $monitor("%d  --->  %b %b %b %b %b",$time, t_a, t_b, t_c, t_out_carry, t_out_sum);
    end

    initial begin 
        t_a = 1'b0;     // 1 
        t_b = 1'b0; 
        t_c = 1'b0;  
        
        #5 //2     
        t_a = 1'b0; 
        t_b = 1'b0; 
        t_c = 1'b1;
        
        #5 //3 
        t_a = 1'b0; 
        t_b = 1'b1; 
        t_c = 1'b0;
        
        #5 //4 
        t_a = 1'b0; 
        t_b = 1'b1; 
        t_c = 1'b1;
        
        #5 //5 
        t_a = 1'b1; 
        t_b = 1'b0; 
        t_c = 1'b0;
        
        #5 //6 
        t_a = 1'b1; 
        t_b = 1'b0; 
        t_c = 1'b1;
        
        #5 //7 
        t_a = 1'b1; 
        t_b = 1'b1; 
        t_c = 1'b0;
    
        #5 //8
        t_a = 1'b1; 
        t_b = 1'b1; 
        t_c = 1'b1;
        
        #10
        $stop;
    end 
endmodule