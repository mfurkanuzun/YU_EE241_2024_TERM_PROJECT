

module ac_control_unit(btn,status,clk);
    input wire clk;
    input wire btn;
    
    reg btn_prev;
    
    output reg status;
    
    always @(posedge clk) begin
        if(btn && ~btn_prev)begin
            status <= ~status;
        end
        
        btn_prev <= btn;
    end
    
endmodule
