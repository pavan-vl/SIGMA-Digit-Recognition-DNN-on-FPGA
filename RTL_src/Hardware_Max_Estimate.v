module DNN_Hardware_max_function  #( parameter NumberOfInputs = 10, inputWdith  =   16)  (
    input                                               clk,
    input                                               in_Valid_i,
    input       [(NumberOfInputs*inputWdith) - 1 : 0]   in_data_i,
    output  reg [ 31 : 0 ]                              out_data_o,
    output  reg                                         out_valid_o
);

reg     [inputWdith - 1 : 0]                    Max_val;
reg     [(NumberOfInputs*inputWdith) - 1 : 0]   In_data_buf;

integer cntr;

always  @   (posedge clk)
begin
    out_valid_o     <=  1'b0;
    if (in_Valid_i) 
    begin
        Max_val         <=  in_data_i[inputWdith - 1 : 0];
        cntr            <=  1'b1;
        In_data_buf     <=  in_data_i;

        out_data_o      <=  0;

    end

    else    if (cntr    ==  NumberOfInputs) 
    begin
        cntr        <= 0;
        out_valid_o <=  1'b1;

    end


    else if(cntr != 0)
    begin
        cntr    <=      cntr    +   1;
        if (In_data_buf[ cntr * inputWdith+: inputWdith] > Max_val) 
        begin
            Max_val     <=  In_data_buf[ cntr * inputWdith+: inputWdith];
            out_data_o  <=  cntr;
        end
    end

end

endmodule
