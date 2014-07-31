function f=fonction_a_fitter(p,abscisse)
%La fonction retournera la valeur de f, que ce soit un tableau, une
%structure, un nombre. La magie de Matlab!
a=p(1);
b=p(2);
%Pas besoin que abscisse et xdata aient le meme nom, tout comme en C.
f=a*abscisse.^2+b;%Tableau qui sera retourne.
end