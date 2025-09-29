//LMP about 4*4 matrix 
module LMP_ctrl 
#(  
    parameter N = 4, // ??????????
    parameter M = 4,       // ??????????
    parameter DATA_WIDTH = 5, // ????????
    parameter INOUT_WIDTH = N*M*DATA_WIDTH
)(
    input wire clk,
    input wire rst_n,
    input wire signed  [INOUT_WIDTH-1:0] A_1,
    output reg signed [N:0] T_max,
    output wire signed  [INOUT_WIDTH-1:0] A_2,
    output wire signed  [INOUT_WIDTH-1:0] A_3,
    output wire signed  [INOUT_WIDTH-1:0] A_4
);
reg [2:0]cnt_clk;//??????????????0??????1????max????2???????
reg cnt_en;//??????????
reg [N-1:0] num;//????
reg [N-1:0] m;//?????????????
reg end_flag;//???????
reg signed [19:0] val_1,val_2,val_3,val_4;//???????
reg signed [DATA_WIDTH-1:0] max_val_1,max_val_2,max_val_3,max_val_4;//???????
wire signed [DATA_WIDTH-1:0] A1[0:N-1][0:M-1] ;
reg signed [DATA_WIDTH-1:0] A2[0:N-1][0:M-1] ;        
reg signed [DATA_WIDTH-1:0] A3[0:N-1][0:M-1] ;                                                    
reg signed [DATA_WIDTH-1:0] A4[0:N-1][0:M-1] ;
assign {A1[0][0],A1[0][1],A1[0][2],A1[0][3],
        A1[1][0],A1[1][1],A1[1][2],A1[1][3],
        A1[2][0],A1[2][1],A1[2][2],A1[2][3],
        A1[3][0],A1[3][1],A1[3][2],A1[3][3]} = A_1;
assign A_2 = {A2[0][0],A2[0][1],A2[0][2],A2[0][3],
              A2[1][0],A2[1][1],A2[1][2],A2[1][3],
              A2[2][0],A2[2][1],A2[2][2],A2[2][3],
              A2[3][0],A2[3][1],A2[3][2],A2[3][3]};
assign A_3 = {A3[0][0],A3[0][1],A3[0][2],A3[0][3],
              A3[1][0],A3[1][1],A3[1][2],A3[1][3],
              A3[2][0],A3[2][1],A3[2][2],A3[2][3],
              A3[3][0],A3[3][1],A3[3][2],A3[3][3]};
assign A_4 = {A4[0][0],A4[0][1],A4[0][2],A4[0][3],
              A4[1][0],A4[1][1],A4[1][2],A4[1][3],
              A4[2][0],A4[2][1],A4[2][2],A4[2][3],
              A4[3][0],A4[3][1],A4[3][2],A4[3][3]};

reg signed [DATA_WIDTH-1:0] T_1,T_2,T_3,T_4;
wire signed [DATA_WIDTH-1:0] T_boundary_1,T_boundary_2,T_boundary_3,T_boundary_4;
integer i, j;
assign T_boundary_1 = T_1;
assign T_boundary_2 = T_2/2;
assign T_boundary_3 = T_3/3;
assign T_boundary_4 = T_4/4;
function [19:0] val;
    input signed  [N:0] A_1 ;
    input signed  [N:0] A_2 ;
    input signed  [N:0] A_3 ;
    input signed  [N:0] A_4 ;
    input signed  [N:0] B_1 ;
    input signed  [N:0] B_2 ;
    input signed  [N:0] B_3 ;
    input signed  [N:0] B_4 ;
    reg signed [N:0] val_1_func,val_2_func,val_3_func,val_4_func;
    begin
        val_1_func = ((A_1==-1 || B_1==-1)) ? -1 : (A_1+B_1);
        val_2_func =((A_2==-1 || B_2==-1)) ? -1 : (A_2+B_2);
        val_3_func = ((A_3==-1 || B_3==-1) ) ? -1 : (A_3+B_3);
        val_4_func = ((A_4==-1 || B_4==-1) ) ? -1 : (A_4+B_4);
        val ={val_1_func,val_2_func,val_3_func,val_4_func};
    end 
endfunction
function [N:0] max_val;
    input signed [19:0] val;
    reg signed [N:0] max_val_1,max_val_2;
    reg signed [N:0] val_1_func,val_2_func,val_3_func,val_4_func;
    begin
        {val_1_func,val_2_func,val_3_func,val_4_func} = val;
        max_val_1 = (val_1_func > val_2_func) ? val_1_func : val_2_func;
        max_val_2 = (val_3_func > val_4_func) ? val_3_func : val_4_func;
        max_val = (max_val_1 > max_val_2) ? max_val_1 : max_val_2;
    end
    endfunction
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_clk <= 0;
    end else if(cnt_clk == 2'd2 && cnt_en) begin
        cnt_clk <= 0;
    end else if(cnt_en) begin
        cnt_clk <= cnt_clk + 1'b1;
    end
    end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        m <= 3'd0;
    end else if (num == N-1 && m == N-1&& cnt_clk == 2'd2 ) begin
        m <= 3'd0;
    end else if (num == N-1&& cnt_clk == 2'd2 ) begin
        m <= m + 3'd1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        num <= 3'd0;
    end else if ( num == M-1&& cnt_clk == 2'd2) begin
        num <= 3'd0;
    end else if ( cnt_clk == 2'd2) begin
        num <= num + 1'b1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        val_1 <= -1;
        val_2 <= -1;
        val_3 <= -1;
        val_4 <= -1;
    end else if(cnt_clk == 2'd0 && m == 3'd0 ) begin
        val_1 <= val(A1[0][0],A1[0][1],A1[0][2],A1[0][3],
                     A1[0][num],A1[1][num],A1[2][num],A1[3][num]);
        val_2 <= val(A1[1][0],A1[1][1],A1[1][2],A1[1][3],
                     A1[0][num],A1[1][num],A1[2][num],A1[3][num]);
        val_3 <= val(A1[2][0],A1[2][1],A1[2][2],A1[2][3],
                     A1[0][num],A1[1][num],A1[2][num],A1[3][num]);
        val_4 <= val(A1[3][0],A1[3][1],A1[3][2],A1[3][3],
                     A1[0][num],A1[1][num],A1[2][num],A1[3][num]);
    end else if(cnt_clk == 2'd0 && m == 3'd1) begin
        val_1 <= val(A1[0][0],A1[0][1],A1[0][2],A1[0][3],
                     A2[0][num],A2[1][num],A2[2][num],A2[3][num]);
        val_2 <= val(A1[1][0],A1[1][1],A1[1][2],A1[1][3],
                     A2[0][num],A2[1][num],A2[2][num],A2[3][num]);
        val_3 <= val(A1[2][0],A1[2][1],A1[2][2],A1[2][3],
                     A2[0][num],A2[1][num],A2[2][num],A2[3][num]);
        val_4 <= val(A1[3][0],A1[3][1],A1[3][2],A1[3][3],
                     A2[0][num],A2[1][num],A2[2][num],A2[3][num]);
    end else if(cnt_clk == 2'd0 && m == 3'd2) begin
        val_1 <= val(A1[0][0],A1[0][1],A1[0][2],A1[0][3],
                     A3[0][num],A3[1][num],A3[2][num],A3[3][num]);
        val_2 <= val(A1[1][0],A1[1][1],A1[1][2],A1[1][3],
                     A3[0][num],A3[1][num],A3[2][num],A3[3][num]);
        val_3 <= val(A1[2][0],A1[2][1],A1[2][2],A1[2][3],
                     A3[0][num],A3[1][num],A3[2][num],A3[3][num]);
        val_4 <= val(A1[3][0],A1[3][1],A1[3][2],A1[3][3],
                     A3[0][num],A3[1][num],A3[2][num],A3[3][num]);
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        cnt_en <= 1'b0;
    end else if (m == 3'd0 && num == 3'd0) begin
        cnt_en <= 1'b1;
    end
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        max_val_1 <= -1;
        max_val_2 <= -1;
        max_val_3 <= -1;
        max_val_4 <= -1;
    end else if(cnt_clk == 2'd1) begin
        max_val_1 <= max_val(val_1);
        max_val_2 <= max_val(val_2);
        max_val_3 <= max_val(val_3);
        max_val_4 <= max_val(val_4);
    end
end

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        for (i = 0; i < N; i = i + 1) begin
        for (j = 0; j < M; j = j + 1) begin
            A2[i][j] <= -1;
        end
    end
    for (i = 0; i < N; i = i + 1) begin
        for (j = 0; j < M; j = j + 1) begin
            A3[i][j] <= -1;
        end
    end
    for (i = 0; i < N; i = i + 1) begin
        for (j = 0; j < M; j = j + 1) begin
            A4[i][j] <= -1;
        end
    end
        end_flag <= 1'b0;
    end else if(m==0 && num==0 && cnt_clk == 2'd2) begin
        A2[0][0] <= max_val_1;
        A2[1][0] <= max_val_2; 
        A2[2][0] <= max_val_3;
        A2[3][0] <= max_val_4;
    end else if(m==0 && num==N-3 && cnt_clk == 2'd2) begin
        A2[0][1] <= max_val_1;
        A2[1][1] <= max_val_2;
        A2[2][1] <= max_val_3;
        A2[3][1] <= max_val_4;
    end else if(m==0 && num==N-2 && cnt_clk == 2'd2) begin
        A2[0][2] <= max_val_1;
        A2[1][2] <= max_val_2;
        A2[2][2] <= max_val_3;
        A2[3][2] <= max_val_4;
    end else if(m==0 && num==N-1 && cnt_clk == 2'd2) begin
        A2[0][3] <= max_val_1;
        A2[1][3] <= max_val_2;
        A2[2][3] <= max_val_3;
        A2[3][3] <= max_val_4;
    end else if(m==1 && num==0 && cnt_clk == 2'd2) begin
        A3[0][0] <= max_val_1;
        A3[1][0] <= max_val_2;
        A3[2][0] <= max_val_3;
        A3[3][0] <= max_val_4;
    end else if(m==1 && num==N-3 && cnt_clk == 2'd2) begin
        A3[0][1] <= max_val_1;
        A3[1][1] <= max_val_2;
        A3[2][1] <= max_val_3;
        A3[3][1] <= max_val_4;
    end else if(m==1 && num==N-2 && cnt_clk == 2'd2) begin
        A3[0][2] <= max_val_1;
        A3[1][2] <= max_val_2;
        A3[2][2] <= max_val_3;
        A3[3][2] <= max_val_4;
    end else if(m==1 && num==N-1 && cnt_clk == 2'd2) begin
        A3[0][3] <= max_val_1;
        A3[1][3] <= max_val_2;
        A3[2][3] <= max_val_3;
        A3[3][3] <= max_val_4;        
    end else if(m==2 && num==0 && cnt_clk == 2'd2) begin
        A4[0][0] <= max_val_1;
        A4[1][0] <= max_val_2;
        A4[2][0] <= max_val_3;
        A4[3][0] <= max_val_4;
    end else if(m==2 && num==N-3 && cnt_clk == 2'd2) begin
        A4[0][1] <= max_val_1;
        A4[1][1] <= max_val_2;
        A4[2][1] <= max_val_3;
        A4[3][1] <= max_val_4;
    end else if(m==2 && num==N-2 && cnt_clk == 2'd2) begin
        A4[0][2] <= max_val_1;
        A4[1][2] <= max_val_2;
        A4[2][2] <= max_val_3;
        A4[3][2] <= max_val_4;
    end else if(m==2 && num==N-1 && cnt_clk == 2'd2) begin
        A4[0][3] <= max_val_1;
        A4[1][3] <= max_val_2;
        A4[2][3] <= max_val_3;
        A4[3][3] <= max_val_4; 
        end_flag <= 1'b1;       
    end
end


always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        T_1 <= 0;
        T_2 <= 0;
        T_3 <= 0;
        T_4 <= 0;    
    end else if(end_flag) begin
        T_1 <= (A1[num][num]>T_1)? A1[num][num]:T_1;
        T_2 <= (A2[num][num]>T_2)? A2[num][num]:T_2;
        T_3 <= (A3[num][num]>T_3)? A3[num][num]:T_3;
        T_4 <= (A4[num][num]>T_4)? A4[num][num]:T_4;
    end 
end
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        T_max <= 0;
    end else if(end_flag && cnt_clk == 2'd2 && num == N-1) begin
        T_max <= (T_boundary_1 >= T_boundary_2 && T_boundary_1 >= T_boundary_3 && T_boundary_1 >= T_boundary_4) ? T_boundary_1 :
                 (T_boundary_2 >= T_boundary_1 && T_boundary_2 >= T_boundary_3 && T_boundary_2 >= T_boundary_4) ? T_boundary_2 :
                 (T_boundary_3 >= T_boundary_1 && T_boundary_3 >= T_boundary_2 && T_boundary_3 >= T_boundary_4) ? T_boundary_3 :
                 T_boundary_4;
    end
end

        endmodule
