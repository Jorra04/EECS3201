module full_adderV (fsum, fcarry_out, a, b, c); 
    input   a, b, c; 
    output  fsum, fcarry_out; 
    wire    half_sum_1, half_carry_1, half_carry_2; 
    
    //module half_adderV(sum, carry, a, b); 
    half_adderV HA1(half_sum_1, half_carry_1, a, b); //instance 1 of Half Adder
    
    //half_adder HA2(fsum, half_carry_2, half_sum_1, c); //instance 2 of Half Adder
    half_adderV HA2(
                    .sum(fsum), 
                    .carry(half_carry_2), 
                    .a(half_sum_1), 
                    .b(c)
                    ); //instance 2 of Half Adder
                        
    or or1(fcarry_out, half_carry_2, half_carry_1); 
    
endmodule