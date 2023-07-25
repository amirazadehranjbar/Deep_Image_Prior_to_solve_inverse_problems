function g=AmirSpatialFilter(im,Type,Size,varargin)

    if nargin<3 || isempty(Size)
        Size=[3 3];
    end
    
    if numel(Size)==1
       Size=[Size Size];
    end

    Type=lower(Type);
    
    switch Type
        case 'median'
            g=medfilt2(im,Size);
            
        case {'average','mean'}
            w=fspecial('average',Size);
            g=imfilter(im,w);
            
        case {'geomtric','gmean','geomean','geomtricmean'}
            g=colfilt(im,Size,'sliding',@GeomtricMean);
            
        case {'harmonic','hmean','harmean','harmonicmean'}
            g=colfilt(im,Size,'sliding',@HarmonicMean);
            
        case {'charmonic','contraharmonic'}
            if isempty(varargin)
                Q=1;
            else
                Q=varargin{1};
            end
            fun=@(x) ContraHarmonicMean(x,Q);
            g=colfilt(im,Size,'sliding',fun);            
            
        case 'max'
            g=ordfilt2(im,prod(Size),true(Size));
            
        case 'min'
            g=ordfilt2(im,1,true(Size));
            
        case 'midpoint'
            gmin=ordfilt2(im,1,true(Size));
            gmax=ordfilt2(im,prod(Size),true(Size));
            g=(gmin+gmax)/2;
            
        case 'alphatrim'
            if isempty(varargin)
                alpha=0.1;
            else
                alpha=varargin{1};
            end
            fun=@(x) AlphaTrimMean(x,alpha);
            g=colfilt(im,Size,'sliding',fun);            
            
        otherwise
            error('Undefined filter type.');
            
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

function chm=ContraHarmonicMean(x,Q)

    chm=sum(x.^(Q+1))./sum(x.^Q);

end

function atm=AlphaTrimMean(x,alpha)

    atm=zeros(1,size(x,2));
    
    for j=1:numel(atm)
        xtj=AlphaTrim(x(:,j),alpha);
        atm(j)=mean(xtj);
    end

end

function xt=AlphaTrim(x,alpha)

    nx=numel(x);
    
    nt=2*round(alpha*nx/2);
    
    xt=sort(x);
    
    xt([1:nt/2 end-nt/2+1:end])=[];

end










