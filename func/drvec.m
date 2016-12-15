function [ rvec_a_b ] = drvec( rvec_a, rvec_b )
%DRVEC �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
R3_a = rodrigues(rvec_a);
R3_b = rodrigues(rvec_b);

R3_a_b = R3_a.'*R3_b;
rvec_a_b = rodrigues(R3_a_b);

end

