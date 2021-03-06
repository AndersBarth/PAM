function [z] = fitfun_2exp(param, xdata)
ShiftParams = xdata{1};
IRFPattern = xdata{2};
Scatter = xdata{3};
p = xdata{4};
y = xdata{5};
c = param(end);%xdata{6}; %IRF shift
ignore = xdata{7};
conv_type = xdata{end}; %%% linear or circular convolution
%%% Define IRF and Scatter from ShiftParams and ScatterPattern!
%irf = circshift(IRFPattern,[c, 0]);
irf = shift_by_fraction(IRFPattern,c);
irf = irf( (ShiftParams(1)+1):ShiftParams(4) );
irf(irf~=0) = irf(irf~=0)-min(irf(irf~=0));
irf = irf./sum(irf);
irf = [irf; zeros(numel(y)+ignore-1-numel(irf),1)];
%Scatter = circshift(ScatterPattern,[ShiftParams(5), 0]);
%A shift in the scatter is not needed in the model
%Scatter = Scatter( (ShiftParams(1)+1):ShiftParams(3) );

n = length(irf);
%t = 1:n;
tp = (1:p)';
A = param(3);
sc = param(4);
bg = param(5);
tau = param(1:2);
tau(tau==0) = 1; %%% set minimum lifetime to TACbin width

x = exp(-(tp-1)*(1./tau))*diag(1./(1-exp(-p./tau)));
%%% combine the two exponentials
x = A*x(:,1) + (1-A)*x(:,2);
switch conv_type
    case 'linear'
        z = zeros(size(x,1)+size(irf,1)-1,size(x,2));
        for i = 1:size(x,2)
            z(:,i) = conv(irf, x(:,i));
        end
        z = z(1:n,:);
    case 'circular'
        z = convol(irf,x(1:n));
end
z = z./repmat(sum(z,1),size(z,1),1);

z = (1-sc).*z + sc*Scatter;
z = z./sum(z);
z = z(ignore:end);
z = z./sum(z);
z = z.*(1-bg)+bg./numel(z);z = z.*sum(y);
z=z';