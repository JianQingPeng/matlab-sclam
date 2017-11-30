classdef ClassCalib < handle
    % class of calibration results, and transform funtions
    % definition of frame cg: camera frame projected on the ground, z axis of
    % camera frame projected onto ground plane and become x axis
    
    properties
        % 3d transform from base frame to camera frame
        T3d_b_c; rvec_b_c; tvec_b_c;
        % 3d transform from base frame to camera ground projected frame
        T3d_b_cg; rvec_b_cg; tvec_b_cg;
        % 3d transform from camera ground projected frame to camera frame
        T3d_cg_c; rvec_cg_c; tvec_cg_c;
        % norm vector of ground plane in camera frame, pointed updard
        pvec_g_c;
        % distance from ground to camera, positive if camera above ground
        dist_g_c;
        % time delay between odo and camera, positive if camera is late
        dt;
        % odometric parameters
        k_odo_lin; k_odo_rot; mat_odo
        % camera intrinsic
        mat_camera; vec_distortion; image_width; image_height;
    end
    
    methods
        % constructor function
        function this = ClassCalib(setting)
            
            if nargin < 1
                this.T3d_b_c = [-1 0 0 0; 0 0 -1 0; 0 -1 0 0; 0 0 0 1];
                RefreshByTbc(this);
            else
                rvec_b_c_init = setting.init.rvec_b_c.';
                tvec_b_c_init = setting.init.tvec_b_c.';
                this.SetVecbc(rvec_b_c_init, tvec_b_c_init);
                this.mat_camera = setting.camera.camera_matrix;
                this.vec_distortion = setting.camera.distortion_coefficients;
            end
            
            this.dt = 0;
            this.k_odo_lin = 1;
            this.k_odo_rot = 1;
            
            this.mat_odo = [0 0; 0 0];
        end
        
        %% write configures ...
        % refresh calibration properties according to _b_c
        RefreshByTbc(this); RefreshByVecbc(this);
        
        % refresh calibration properties according to _b_cg and _cg_c
        RefreshByTbcgc(this); RefreshByVecbcgc(this);
        
        % refresh calibration properties according to pvec_g_c and dist_g_c
        RefreshByGrnd(this);
        
        % set ps2d_b_cg
        function SetPs2dbcg(this, ps2d_b_cg)
            this.rvec_b_cg = [0;0;ps2d_b_cg(3)];
            this.tvec_b_cg = [ps2d_b_cg(1:2);0];
            RefreshByVecbcgc(this);
        end
        
        % set T_b_c by rodrigues vec and translational vec
        function SetVecbc(this, rvec_b_c, tvec_b_c)
            this.rvec_b_c = rvec_b_c;
            this.tvec_b_c = tvec_b_c;
            RefreshByVecbc(this);
        end
        
        % set camera intrinsics
        function SetCameraIntrinsic(this, mat_camera, vec_distortion)
            this.mat_camera = mat_camera;
            this.vec_distortion = vec_distortion;
        end
        
        % set odometry intrinsic
        function SetOdometryIntrinsic(this, k_odo_lin, k_odo_rot)
            this.k_odo_lin = k_odo_lin;
            this.k_odo_rot = k_odo_rot;
        end
        
        % set temporal delay
        function SetTemporal(this, dt)
            this.dt = dt;
        end
        
        %% read configures ...
        
        % get ps2d_b_cg
        function ps2d_b_cg = GetPs2dbcg(this)
            ps2d_b_cg = zeros(3,1);
            ps2d_b_cg(3) = this.rvec_b_cg(3);
            ps2d_b_cg(1:2) = this.tvec_b_cg(1:2);
        end
        
        % display ps2d_b_cg
        function DispPs2dbcg(this)
            ps2d_b_cg = this.GetPs2dbcg;
            disp(['Current estimated ps2d_b_cg: ', num2str(ps2d_b_cg(1)), ' ', ...
                num2str(ps2d_b_cg(2)), ' ', num2str(ps2d_b_cg(3)), ' ']);
            disp(' ');
        end
        
        % display all vec
        function DispCalib(this)
            rvec_b_c = this.rvec_b_c;
            disp(['Current estimated rvec_b_c: ', num2str(rvec_b_c(1)), ' ', ...
                num2str(rvec_b_c(2)), ' ', num2str(rvec_b_c(3)), ' ']);
            
            tvec_b_c = this.tvec_b_c;
            disp(['Current estimated tvec_b_c: ', num2str(tvec_b_c(1)), ' ', ...
                num2str(tvec_b_c(2)), ' ', num2str(tvec_b_c(3)), ' ']);
            
            %             rvec_b_cg = this.rvec_b_cg;
            %             disp(['Current estimated rvec_b_cg: ', num2str(rvec_b_cg(1)), ' ', ...
            %                 num2str(rvec_b_cg(2)), ' ', num2str(rvec_b_cg(3)), ' ']);
            %
            %             tvec_b_cg = this.tvec_b_cg;
            %             disp(['Current estimated tvec_b_cg: ', num2str(tvec_b_cg(1)), ' ', ...
            %                 num2str(tvec_b_cg(2)), ' ', num2str(tvec_b_cg(3)), ' ']);
            %
            %             rvec_cg_c = this.rvec_cg_c;
            %             disp(['Current estimated rvec_cg_c: ', num2str(rvec_cg_c(1)), ' ', ...
            %                 num2str(rvec_cg_c(2)), ' ', num2str(rvec_cg_c(3)), ' ']);
            %
            %             tvec_cg_c = this.tvec_cg_c;
            %             disp(['Current estimated tvec_cg_c: ', num2str(tvec_cg_c(1)), ' ', ...
            %                 num2str(tvec_cg_c(2)), ' ', num2str(tvec_cg_c(3)), ' ']);
            
%             dt = this.dt;
%             disp(['Current estimated dt: ', num2str(dt), ' ']);
%             
%             k_odo_lin = this.k_odo_lin;
%             k_odo_rot = this.k_odo_rot;
%             disp(['Current estimated k_odo_lin k_odo_rot: ', ...
%                 num2str(k_odo_lin), ' ', num2str(k_odo_rot), ' ']);
            
%             fx = this.mat_camera(1,1);
%             fy = this.mat_camera(2,2);
%             cx = this.mat_camera(1,3);
%             cy = this.mat_camera(2,3);
%             disp(['Current estimated fx fy cx cy: ', ...
%                 num2str(fx), ' ', num2str(fy), ' ', ...
%                 num2str(cx), ' ', num2str(cy), ' ']);
%             
%             distortion = this.vec_distortion;
%             disp(['Current estimated distortion: ', num2str(distortion(1)), ' ', ...
%                 num2str(distortion(2)), ' ', num2str(distortion(3)), ' ', ...
%                 num2str(distortion(4)), ' ', num2str(distortion(5)), ' ']);

            mat_odo = this.mat_odo;
            disp(['Current estimated mat_odo: [', ...
                num2str(mat_odo(1,1)), ' ', num2str(mat_odo(1,2)), '; ',...
                num2str(mat_odo(2,1)), ' ', num2str(mat_odo(2,2)), '; ]']);
            
            disp(' ');
        end
        
        function struct_result = GetCalibResult(this)
            struct_result.rvec_b_c = this.rvec_b_c;
            struct_result.tvec_b_c = this.tvec_b_c;
            struct_result.mat_odo = this.mat_odo;
            struct_result.mat_camera = this.mat_camera;
            struct_result.vec_distortion = this.vec_distortion;
        end
    end
end

