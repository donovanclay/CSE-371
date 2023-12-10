module laser_draw #(
    parameter PLAYER_HEIGHT = 32,
    parameter PLAYER_WIDTH = 32,
    parameter LASER_WIDTH = 5,
    parameter LASER_LENGTH = 10,
    parameter ALIEN_WIDTH = 40,
    parameter ALIEN_HEIGHT = 21,
    parameter ALIEN_GAP = 21,
    parameter BACKGROUND_COLOR_NUM = 0,
    parameter LASER_COLOR_NUM = 2
) (
    input logic clock, global_reset, laser_draw_reset, fire, alien_alive_data_in,
    input logic [9:0] player_x, alien_group_x,
    input logic [8:0] player_y, alien_group_y,
    output logic [4:0] out_which_alien,
    output logic [3:0] out_which_color,
    output logic out_alien_alive_data, out_laser_done, out_alien_alive_wren, out_laser_alive,
    output logic [9:0] out_x,
    output logic [8:0] out_y,
    output logic [3:0] which_state
);

    logic laser_alive, just_shot, erase, check_aliens_done, check_aliens_reset, alien_killed, next_offscreen;
    logic [9:0] input_x, curr_x, prev_x;
    logic [8:0] input_y, curr_y, prev_y;
    logic [4:0] check_alien_which_alien, which_alien_writing;

    assign out_laser_alive = laser_alive;
    assign next_offscreen = (input_y <= 5);

    enum {s_global_reset, s_last_pixel, s_fire, s_start, s_first_draw, s_not_first_draw, s_draw, s_check_next_offscreen, s_check_aliens, s_update_aliens, s_done_updating_aliens, s_done} ps, ns;
    assign out_which_alien = (ps != s_update_aliens) ? check_alien_which_alien : which_alien_writing;
    logic alien_alive_wren_local;
    assign out_alien_alive_wren = (ps == s_update_aliens);
    
    assign which_state = ps;
    assign out_laser_done = (ps == s_done);
    assign out_which_color = (erase) ? BACKGROUND_COLOR_NUM : LASER_COLOR_NUM;

    always_comb begin
        case (ps)
            s_fire:
                ns = s_fire;

            s_global_reset:
                ns = s_global_reset;

            s_start: begin
                if (laser_alive) begin
                    if (just_shot)
                        ns = s_first_draw;
                    else
                        ns = s_not_first_draw;
                end
                else
                    ns = s_done;
            end

            s_not_first_draw:
                ns = s_draw;

            s_first_draw:
                ns = s_draw;
                
            s_last_pixel: begin
                if (laser_alive)
                    ns = s_draw;
                else
                    ns = s_done;
            end


            s_draw: begin
                // not incrementing x
                if ((!erase && curr_x == input_x + (LASER_WIDTH / 2)) ||
                    (erase && curr_x == prev_x + (LASER_WIDTH / 2))) begin
                    
                    // not incrementing y
                    if ((!erase && curr_y == input_y + (LASER_LENGTH)) ||
                        (erase && curr_y == prev_y + (LASER_LENGTH))) begin
                            
                        // erasing
                        if (erase) begin
                            ns = s_last_pixel;
                        end
                        
                        // not erasing
                        else
                            ns = s_check_next_offscreen;
                    end

                    // incrementing y
                    else
                        ns = s_draw;
                end

                // incrementing x
                else
                    ns = s_draw;
            end

            s_check_next_offscreen: begin
                if (next_offscreen)
                    ns = s_done;
                else
                    ns = s_check_aliens;
            end

            s_check_aliens: begin
                if (check_aliens_done) begin
                    if (alien_killed)
                        ns = s_update_aliens;
                    else
                        ns = s_done;
                end

                else
                    ns = s_check_aliens;
            end
            
            s_update_aliens:
                ns = s_done_updating_aliens;

            s_done_updating_aliens:
                ns = s_done;

            s_done:
                ns = s_done;
        endcase
    end

    always_ff @(posedge clock) begin
        if (ps == s_global_reset) begin
            laser_alive = 0;
            just_shot = 0;
            {input_x, curr_x, prev_x, out_x} = 40'bZ;
            {input_y, curr_y, prev_y, out_y} = 36'bZ;
            erase = 0;
            out_alien_alive_data = 1'b0;
            check_aliens_reset = 1;
        end
        
        if (ps == s_last_pixel) begin
            out_x = curr_x;
            out_y = curr_y;
            
            if (laser_alive) begin
                // setup for drawing the new laser
                erase = 0;
                curr_x = input_x - (LASER_WIDTH / 2);
                curr_y = input_y;
                prev_x = input_x;
                prev_y = input_y;
            end
        end

        if (ps == s_fire) begin
            laser_alive = 1;
            input_x = player_x;
            input_y = player_y - (PLAYER_HEIGHT / 2 + LASER_LENGTH);
            curr_x = player_x - (LASER_WIDTH / 2);
            curr_y = player_y - (PLAYER_HEIGHT / 2 + LASER_LENGTH);
            prev_x = player_x;
            prev_y = player_y - (PLAYER_HEIGHT / 2 + LASER_LENGTH);
            erase = 0;
            just_shot = 1;
        end

        if (ps == s_start) begin
            
        end

        if (ps == s_first_draw) begin
            just_shot = 0;
            erase = 0;
        end

        if (ps == s_not_first_draw) begin
            erase = 1;
            curr_x = prev_x - (LASER_WIDTH / 2);
            curr_y = prev_y;
        end

        if (ps == s_draw) begin
            out_x = curr_x;
            out_y = curr_y;
            
            // not incrementing x
            if ((!erase && curr_x == input_x + (LASER_WIDTH / 2)) ||
                (erase && curr_x == prev_x + (LASER_WIDTH / 2))) begin
                
                // not incrementing y
                if ((!erase && curr_y == input_y + (LASER_LENGTH)) ||
                    (erase && curr_y == prev_y + (LASER_LENGTH))) begin
                        
                    // erasing
                    if (erase) begin

                        // laser dead
                    end
                    
                    // not erasing
                end

                // incrementing y
                else begin
                    curr_y++;
                    if (erase)
                        curr_x = prev_x - (LASER_WIDTH / 2);
                    else
                        curr_x = input_x - (LASER_WIDTH / 2);
                end
                   
            end

            // incrementing x
            else
                curr_x++;
        end

        if (ps == s_check_next_offscreen) begin
            if (next_offscreen)
                laser_alive = 1'b0;
            else begin
                input_y = input_y - 5;
                check_aliens_reset = 1'b1;
            end
        end

        if (ps == s_check_aliens) begin
            check_aliens_reset = 1'b0;
            if (check_aliens_done) begin
                if (alien_killed)
                    which_alien_writing = check_alien_which_alien - 1;
            end
        end

        if (ps == s_update_aliens) begin
            out_alien_alive_data = 1'b0;
            which_alien_writing = which_alien_writing - 1;
            laser_alive = 1'b0;
        end

        if (ps == s_done_updating_aliens) begin
            out_alien_alive_data = 1'b0;

        end
    end

    alien_check #(
        .ALIEN_WIDTH(ALIEN_WIDTH),
        .ALIEN_HEIGHT(ALIEN_HEIGHT),
        .ALIEN_GAP(ALIEN_GAP),
        .LASER_WIDTH(LASER_WIDTH)
    ) my_alien_checker (
        .clock(clock),
        .alien_check_reset(check_aliens_reset),
        .alien_alive(alien_alive_data_in),
        .input_laser_x(input_x),
        .input_laser_y(input_y),
        .alien_group_x(alien_group_x),
        .alien_group_y(alien_group_y),
        .which_alien_out(check_alien_which_alien),
        .done(check_aliens_done), 
        .alien_killed(alien_killed)
    );

    always_ff @(posedge clock) begin
        if (global_reset)
            ps = s_global_reset;
        else if (laser_draw_reset)
            ps = s_start;
        else if (fire && !laser_alive)
            ps = s_fire;
       
        else
            ps = ns;
    end
endmodule
// module laser_draw2 #(
//     parameter PLAYER_HEIGHT = 32,
//     parameter PLAYER_WIDTH = 32,
//     parameter LASER_WIDTH = 5,
//     parameter LASER_LENGTH = 10,
//     parameter ALIEN_WIDTH = 40,
//     parameter ALIEN_HEIGHT = 21,
//     parameter ALIEN_GAP = 21,
//     parameter BACKGROUND_COLOR_NUM = 0,
//     parameter LASER_COLOR_NUM = 2
// ) (
//     input logic clock, global_reset, laser_draw_reset, fire, alien_alive_data_in,
//     input logic [9:0] player_x, alien_group_x,
//     input logic [8:0] player_y, alien_group_y,
//     // output logic [4:0] out_which_alien_read, out_which_alien_write,
//     output logic [4:0] out_which_alien,
//     output logic [3:0] out_which_color,
//     output logic out_alien_alive_data, out_laser_done, out_alien_alive_wren, out_laser_alive,
//     output logic [9:0] out_x,
//     output logic [8:0] out_y,
//     output logic [3:0] which_state
// );

//     logic laser_alive, just_shot, erase, check_aliens_done, check_aliens_reset, alien_killed, next_offscreen;
//     logic [9:0] input_x, curr_x, prev_x;
//     logic [8:0] input_y, curr_y, prev_y;
//     logic [4:0] check_alien_which_alien, which_alien_writing;

    
//     assign out_laser_alive = laser_alive;
//     assign next_offscreen = (input_y <= 5);
   

//     // enum {s_global_reset = 1, s_fire = 2, s_fire2 = 12, s_start = 3, s_first_draw = 4, s_not_first_draw = 5, s_draw = 6, s_check_next_offscreen = 7, s_check_aliens = 8, s_update_aliens = 9, s_done_updating_aliens = 10, s_done = 11} ps, ns;
//     enum {s_global_reset = 1, s_last_pixel = 12, s_fire = 2, s_start = 3, s_first_draw = 4, s_not_first_draw = 5, s_draw = 6, s_check_next_offscreen = 7, s_check_aliens = 8, s_update_aliens = 9, s_done_updating_aliens = 10, s_done = 11} ps, ns;
//     assign out_which_alien = (ps != s_update_aliens) ? check_alien_which_alien : which_alien_writing;
//      assign out_alien_alive_wren = (ps == s_update_aliens);
//     // logic [3:0] which_state;
    
//     assign which_state = ps;
//     assign out_laser_done = (ps == s_done);
//     assign out_which_color = (erase) ? BACKGROUND_COLOR_NUM : LASER_COLOR_NUM;

//     always_comb begin
//         case (ps)
//             s_fire:
//                 // ns = s_fire;
//                 // if (laser_draw_reset)
//                     // ns = s_fire2;
//                     // ns = s_start;
//                 // else
//                     ns = s_fire;
//                 // ns = s_done;

//             // s_fire2:
//                 // ns = s_fire;

//             s_global_reset:
//                 ns = s_global_reset;

//             s_start: begin
//                 if (laser_alive) begin
//                     if (just_shot)
//                         ns = s_first_draw;
//                     else
//                         ns = s_not_first_draw;
//                 end
//                 else
//                     ns = s_done;
//             end

//             s_not_first_draw:
//                 ns = s_draw;

//             s_first_draw:
//                 ns = s_draw;
                
//             s_last_pixel: begin
//                 if (laser_alive)
//                     ns = s_draw;
//                 else
//                     ns = s_done;
//             end


//             s_draw: begin
//                 // not incrementing x
//                 if ((!erase && curr_x == input_x + (LASER_WIDTH / 2)) ||
//                     (erase && curr_x == prev_x + (LASER_WIDTH / 2))) begin
                    
//                     // not incrementing y
//                     if ((!erase && curr_y == input_y + (LASER_LENGTH)) ||
//                         (erase && curr_y == prev_y + (LASER_LENGTH))) begin
                            
//                         // erasing
//                         if (erase) begin
//                             ns = s_last_pixel;
//                             // laser is still alive to draw the laser in the new location
//                             // if (laser_alive)
//                             //     ns = s_draw;
//                             // else
//                             //     ns = s_done;
//                         end
                        
//                         // not erasing
//                         else
//                             ns = s_check_next_offscreen;
//                     end

//                     // incrementing y
//                     else
//                         ns = s_draw;
//                 end

//                 // incrementing x
//                 else
//                     ns = s_draw;
//             end

//             s_check_next_offscreen: begin
//                 if (next_offscreen)
//                     ns = s_done;
//                 else
//                     ns = s_check_aliens;
//             end

//             s_check_aliens: begin
//                 if (check_aliens_done) begin
//                     if (alien_killed)
//                         ns = s_update_aliens;
//                     else
//                         ns = s_done;
//                 end

//                 else
//                     ns = s_check_aliens;
//             end
            
//             s_update_aliens:
//                 ns = s_done_updating_aliens;

//             s_done_updating_aliens:
//                 ns = s_done;

//             s_done:
//                 ns = s_done;
//         endcase
//     end

//     always_ff @(posedge clock) begin
//         if (ps == s_global_reset) begin
//             laser_alive = 0;
//             just_shot = 0;
//             {input_x, curr_x, prev_x, out_x} = 40'bZ;
//             {input_y, curr_y, prev_y, out_y} = 36'bZ;
//             erase = 0;
//             // out_alien_alive_wren = 1'b0;
//             out_alien_alive_data = 1'b0;
//             // out_which_alien_write = 5'bZ;
//             check_aliens_reset = 1;
//         end
        
//         if (ps == s_last_pixel) begin
//             out_x = curr_x;
//             out_y = curr_y;
            
//             if (laser_alive) begin
//                             // setup for drawing the new laser
//                             erase = 0;
//                             curr_x = input_x - (LASER_WIDTH / 2);
//                             curr_y = input_y;
//                             prev_x = input_x;
//                             prev_y = input_y;
//             end
//         end

//         if (ps == s_fire) begin
//             laser_alive = 1;
//             input_x = player_x;
//             input_y = player_y - (PLAYER_HEIGHT / 2 + LASER_LENGTH);
//             curr_x = player_x - (LASER_WIDTH / 2);
//             curr_y = player_y - (PLAYER_HEIGHT / 2 + LASER_LENGTH);
//             prev_x = player_x;
//             prev_y = player_y - (PLAYER_HEIGHT / 2 + LASER_LENGTH);
//             erase = 0;
//             just_shot = 1;
//         end

//         if (ps == s_start) begin
            
//         end

//         if (ps == s_first_draw) begin
//             just_shot = 0;
//             erase = 0;
//         end

//         if (ps == s_not_first_draw) begin
//             erase = 1;
//             curr_x = prev_x - (LASER_WIDTH / 2);
//             curr_y = prev_y;
//         end

//         if (ps == s_draw) begin
//             out_x = curr_x;
//             out_y = curr_y;
//             // out_alien_alive_wren = 1'b0;
            
//             // not incrementing x
//             if ((!erase && curr_x == input_x + (LASER_WIDTH / 2)) ||
//                 (erase && curr_x == prev_x + (LASER_WIDTH / 2))) begin
                
//                 // not incrementing y
//                 if ((!erase && curr_y == input_y + (LASER_LENGTH)) ||
//                     (erase && curr_y == prev_y + (LASER_LENGTH))) begin
                        
//                     // erasing
//                     if (erase) begin
//                         // laser is still alive to draw the laser in the new location
//                         // if (laser_alive)
//                         //     // setup for drawing the new laser
//                         //     erase = 0;
//                         //     curr_x = input_x - (LASER_WIDTH / 2);
//                         //     curr_y = input_y;
//                         //     prev_x = input_x;
//                         //     prev_y = input_y;

//                         // laser dead
//                     end
                    
//                     // not erasing
//                 end

//                 // incrementing y
//                 else begin
//                     curr_y++;
//                     if (erase)
//                         curr_x = prev_x - (LASER_WIDTH / 2);
//                     else
//                         curr_x = input_x - (LASER_WIDTH / 2);
//                 end
                   
//             end

//             // incrementing x
//             else
//                 curr_x++;
//         end

//         if (ps == s_check_next_offscreen) begin
//             // out_alien_alive_wren = 1'b0;
//             if (next_offscreen)
//                 laser_alive = 1'b0;
//             else begin
//                 input_y = input_y - 5;
//                 check_aliens_reset = 1'b1;
//             end
//         end

//         if (ps == s_check_aliens) begin
//             check_aliens_reset = 1'b0;
//             // out_alien_alive_wren = 1'b0;
//         end

//         if (ps == s_update_aliens) begin
//             // out_alien_alive_wren = 1'b1;
//             out_alien_alive_data = 1'b0;
//             // out_which_alien_write = out_which_alien_read;
//             which_alien_writing = check_alien_which_alien;
//             laser_alive = 1'b0;
//         end

//         if (ps == s_done_updating_aliens) begin
//             // out_alien_alive_wren = 1'b0;
//             out_alien_alive_data = 1'b0;

//         end
//     end

//     alien_check #(
//         .ALIEN_WIDTH(ALIEN_WIDTH),
//         .ALIEN_HEIGHT(ALIEN_HEIGHT),
//         .ALIEN_GAP(ALIEN_GAP),
//         .LASER_WIDTH(LASER_WIDTH)
//     ) my_alien_checker (
//         .clock(clock),
//         .alien_check_reset(check_aliens_reset),
//         .alien_alive(alien_alive_data_in),
//         .input_laser_x(input_x),
//         .input_laser_y(input_y),
//         .alien_group_x(alien_group_x),
//         .alien_group_y(alien_group_y),
//         .which_alien_out(check_alien_which_alien),
//         .done(check_aliens_done), 
//         .alien_killed(alien_killed)
//     );

//     always_ff @(posedge clock) begin
//         if (global_reset)
//             ps = s_global_reset;
//         else if (laser_draw_reset)
//             ps = s_start;
//         else if (fire && !laser_alive)
//             ps = s_fire;
       
//         else
//             ps = ns;
//     end
// endmodule

// module laser_draw2_tb();
//     logic clock, global_reset, laser_draw_reset, fire, alien_alive_data_in;
//     logic [9:0] player_x, alien_group_x;
//     logic [8:0] player_y, alien_group_y;
//     // logic [4:0] out_which_alien_read, out_which_alien_write;
//     logic [4:0] out_which_alien;
//     logic [3:0] out_which_color;
//     logic out_alien_alive_data, out_laser_done, out_alien_alive_wren, out_laser_alive;
//     logic [9:0] out_x;
//     logic [8:0] out_y;

//     laser_draw2 dut (.*);

//     parameter CLOCK_PERIOD = 100;
//     initial begin
//         clock <= 0;
//         forever #(CLOCK_PERIOD/2) clock <= ~clock;
//     end

//     integer i, j;
//     initial begin
//         global_reset <= 1; fire <= 0; alien_alive_data_in <= 1; laser_draw_reset <= 0;
//         player_x <= 320; player_y <= 454; alien_group_x <= 320; alien_group_y <= 105; @(posedge clock);
//                             @(posedge clock);
//         global_reset <= 0;  @(posedge clock);

//         for (i = 0; i < 7; i++) begin
//                             @(posedge clock);
//         end
//         fire <= 1;          @(posedge clock);
//         fire <= 0;          @(posedge clock);

//         for (i = 0; i < 7; i++) begin
//                             @(posedge clock);
//         end

//         laser_draw_reset <= 1;      @(posedge clock);
//         laser_draw_reset <= 0;      @(posedge clock);
//         for (i = 0; i < 7 * 5; i++) begin
//                             @(posedge clock);
//         end
//         fire <= 1;          @(posedge clock);
//         fire <= 0;          @(posedge clock);
//         for (i = 0; i < 7 * 5; i++) begin
//                             @(posedge clock);
//         end
//         fire <= 1;          @(posedge clock);
//         fire <= 0;          @(posedge clock);
//         laser_draw_reset <= 1;      @(posedge clock);
//         laser_draw_reset <= 0;      @(posedge clock);

//         for (i = 0; i < 7 * 5; i++) begin
//                             @(posedge clock);
//         end
//         fire <= 1;          @(posedge clock);
//         fire <= 0;          @(posedge clock);
//         for (i = 0; i < 7 * 5; i++) begin
//                             @(posedge clock);
//         end

//         for (j = 0; j < 100; j++) begin
//             laser_draw_reset <= 1;      @(posedge clock);
//             laser_draw_reset <= 0;      @(posedge clock);

//             for (i = 0; i < 7 * 17; i++) begin
//                                 @(posedge clock);
//             end
//         end

//         $stop;
//     end

// endmodule