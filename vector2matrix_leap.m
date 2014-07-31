% Programme qui met 366 jours par annee en mettant des NaN dans les annees
% non-bisextiles
% Fait par : Blaise Gauvin St-Denis
% Derniere modification : 16 mai 2014


function [matrice1] = vector2matrix_leap(date,data)

matrice1 = zeros([366,2099-1961+1]);
for yyyy=1961:2099
    indices = find(date(:,1)==yyyy);
    days_in_month = scen_calendar_month(yyyy,'gregorian');
    if days_in_month(2) == 28
        matrice1(1:365,yyyy-1961+1) = data(indices);
    elseif days_in_month(2) == 29
        matrice1(1:366,yyyy-1961+1) = data(indices);
    end
    if days_in_month(2) == 28
        matrice1(61:end,yyyy-1961+1) = matrice1(60:end-1,yyyy-1961+1);
        matrice1(60,yyyy-1961+1) = NaN;
    end
end