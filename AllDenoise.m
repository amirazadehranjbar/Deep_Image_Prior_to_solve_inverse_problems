function Dim=AllDenoise(im,Type,varargin)

switch Type
    case {'nlinfilter','nlfilter'}
        [Dim,estDeSm] =imnlmfilt(im);
        disp(['Estimated Degree of Smoothing = ',num2str(estDeSm)]);

    case {'guidedfilter','gdfilt'}
        Dim=imguidedfilter(im);
        disp('Denoise Using imguidedfilter')    

    case {'gaussianfilter','guasfilt'}
        Dim=imgaussfilt(im);
        disp('Denoise Using imgaussfilt')

    case {'netdenoise','netde'}
        net=denoisingNetwork("dncnn");
        Dim=denoiseImage(im,net);
        disp('Denoise Using denoisingNetwork')

    case 'deconv'
        Size=varargin{1};
        InitialPSF=fspecial('average',Size);
        Dim=deconvblind(im,InitialPSF);
        disp('Denoise Using deconvblind')

    case 'bilatfilter'
        DegreeOfSmoothing=varargin{1};
        Dim=imbilatfilt(im,DegreeOfSmoothing);
        disp('Denoise Using imbilatfilt')

    case 'diffusfilter'
        [gradThresh , numInter]=imdiffuseest(im);
        Dim=imdiffusefilt(im,"GradientThreshold",gradThresh,"NumberOfIterations",numInter);
        disp('Denoise Using imdiffusefilt')
    case 'goemetricmean'
       Size=varargin{1};
       Dim=colfilt(im,Size,'sliding',@ GeomtricMean);
       disp('denoise Using Geometric Mean')
       
    case 'harmonicmean'
        Size=varargin{1};
        Dim=colfilt(im,Size,'sliding',@HarmonicMean);
        disp('Denoise Using Harmonic Mean')
end
end

function gm=GeomtricMean(x)

    epsilon=0.001;
    %x=max(x,epsilon);
    x=(1-epsilon)*x+epsilon;
    
    gm=exp(mean(log(x)));

end

function hm=HarmonicMean(x)

    epsilon=0.001;
    x=max(x,epsilon);
    %x=(1-epsilon)*x+epsilon;

    hm=1./mean(1./x);

end