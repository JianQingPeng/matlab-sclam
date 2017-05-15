function InitBasePose(this, measure)
%INITBASEPOSE(THIS, MEASURE); �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

if ~isequal(size(this.vec_mu_x), [6,1])
    error('Extrinsic parameter has not been initialized!!!');
end

% read the first record
lp = measure.odo.lp(1);
x_o_b = measure.odo.x(1);
y_o_b = measure.odo.y(1);
theta_o_b = measure.odo.theta(1);
se2_o_b = [x_o_b; y_o_b; theta_o_b];

% init vec_mu_x and mat_Sigma_x
this.vec_mu_x(7:9) = se2_o_b;
this.mat_Sigma_x(7:9, 7:9) = 1e-6 * eye(3);

this.lp_now = lp;

end

