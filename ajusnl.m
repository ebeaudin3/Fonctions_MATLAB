function [p,dp,chi2n]=ajusnl(fonction,p0,eval,x,y,sigy,varargin)
%function [p,dp,chi2n]=ajusnl(fonction,p0,eval,x,y,sigy,varargin)
% ENTR�E:
%	fonction: nom de la fonction qui calcule le chi carr�
%	p0: param�tres initiaux
%	x et y: points exp�rimentaux
%   eval: # evaluations; si 0 , valeur defaut.
%	sigy: incertitudes sur y; si inconnues, mettre 0;
%	varargin: structure qui englobe tous les autres param�tres � passer � fonction
% SORTIE
%	p: param�tres optimis�s
%	dp: incertitudes sur p
%	chi2n: chi carr� normalis�

if sigy==0
   sigyp=1;
else
    sigyp=sigy;
end
if eval>0
    opt=optimset('maxiter',eval);
else
    opt=[];
end
[p,chi2,a,a,a,h]=fminunc(fonction,p0,opt,x,y,sigyp,varargin{:});
if sigy==0
   dp=erreur(h,chi2,p,x);
else
   dp=erreur(h);
end
chi2n=chi2/(length(x(:))-length(p(:)));
