clear
%Je genere l'abscisse
xdata=-10:0.1:10;
%Je genere l'ordonnee sans bruit
ydata=2*xdata.^2+3;
plot(xdata,ydata,'r-')
%J'ajoute un tantinet de bruit correspondant a une incertitude d'approx.
%dix pourcent sur la mesure
ydata=(1+0.05*(1-13*rand(size(ydata)))).*ydata;
hold on
plot(xdata,ydata,'b--')
% On utilise lsqcurvefit et la fonction fonction_a_fitter pour tenter de
% retrouver nos parametres originaux. On fournit un estime des valeurs des
% parametres (on determine ceci a l'oeil) comme etant [1.8 2.7] (mettons).
 p=lsqcurvefit_e(@(p,xdata) fonction_a_fitter(p,xdata),[1.8 2.7],xdata,ydata)
 plot(xdata,fonction_a_fitter(p,xdata),'g-') 
 hold off
 %p est un vecteur dont les ?l?ments correspondent au valeurs ajust?es. Au
 %lieu d'?crire [1.8 2.7], on aurait pu d?finir p0=[1.8 2.7]; et ensuite
%  %?crire 
%  p=lsqcurvefit(@(p,xdata) fonction_a_fitter(p,xdata),p0,xdata,ydata);
 %Vous remarquerez que le r?sultat n'est pas toujours aussi proche des valeurs
 %attendues. Vous pouvez r?duire la tol?rance de lsqcurvefit (c'est relativement complexe) ou
 %effectuer l'ajustement sur plus de points. Pour vous en convaincre,essayez de nouveau, mais en
 %changeant cette fois le pas de xdata. Plus il y a de parametres a
 %ajuster, plus vous aurez besoin de points pour arriver ? un r?sultat
 %concluant!