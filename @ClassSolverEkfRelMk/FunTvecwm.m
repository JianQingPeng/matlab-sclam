function tvec_w_m = FunTvecwm( this, rvec_b_c, tvec_b_c, se2_w_b, tvec_c_m )
%FUNTVECWM �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��

T_b_c = FunVec2Trans3d( rvec_b_c, tvec_b_c );
T_w_b = FunPs2d2T3d(se2_w_b);
T_w_c = T_w_b*T_b_c;
tvec_w_m_bar = T_w_c * [tvec_c_m;1];
tvec_w_m = tvec_w_m_bar(1:3);

end

