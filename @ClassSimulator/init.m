function Init( this, name_sim_fold )
%INIT init function, load map and calib info, set output path, ...

name_setting_file = [name_sim_fold, 'config/setting-sim.yml'];
this.files.str_simfolder = name_sim_fold;
this.files.str_path_setting = name_setting_file;
this.setting = YAML.read(this.files.str_path_setting);

%% reading map data
disp('Reading map data...');
sz = size(this.setting.map);
numMk = sz(1);
for i = 1:numMk
    mk_tmp = this.setting.map(i,:);
    this.map.mks.id = [this.map.mks.id; mk_tmp(1)];
    this.map.mks.rvec_w_m = [this.map.mks.rvec_w_m; mk_tmp(2:4)];
    this.map.mks.tvec_w_m = [this.map.mks.tvec_w_m; mk_tmp(5:7)];
end
disp('All map data loaded.');
disp(' ');

%% reading config data
disp('Reading camera config...');
this.calib.rvec_b_c = this.setting.camera.rvec_b_c;
this.calib.rvec_b_c = this.setting.camera.rvec_b_c;
this.calib.mat_camera = this.setting.camera.camera_matrix;
this.calib.vec_distortion = this.setting.camera.distortion_coefficients;
this.calib.image_width = this.setting.camera.image_width;
this.calib.image_height = this.setting.camera.image_height;
% this.calib.dt = this.setting.temporal.dt_b_c;
this.calib.k_odo_lin = this.setting.odometry.k_lin;
this.calib.k_odo_rot = this.setting.odometry.k_rot;
this.calib.mat_odo = this.setting.odometry.odo_matrix;

this.calib.RefreshByVecbc;
disp('All camera config data loaded.');
disp(' ');


end

