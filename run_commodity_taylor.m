% Set policy to TAYLOR
txt = fileread('commodity2.mod');
txt = regexprep(txt, ...
    '@#define POLICY\s*=\s*".*?"', ...
    '@#define POLICY = "TAYLOR"');

fid = fopen('commodity2_tmp.mod', 'w');
fwrite(fid, txt);
fclose(fid);

% Run Dynare
dynare commodity2_tmp noclearall

% Variables to plot
vars = {'pi','pi_h','y_h','c','n','wr','i','e','s','p_tildec'};
titles = {'CPI inflation', ...
          'Domestic inflation', ...
          'Output', ...
          'Consumption', ...
          'Employment', ...
          'Real wage', ...
          'Interest rate', ...
          'Nominal exchange rate', ...
          'Real exchange rate', ...
          'Commodity price'};

figure;


for k = 1:length(vars)

    
    if ismember(vars{k}, {'pi','pi_h','i'})
        scale = 400;    % annualized percent
    else
        scale = 100;    % percent deviation
    end
    
    subplot(4,3,k);
    hold on;

    plot(scale*oo_.irfs.([vars{k} '_eps_ptcstar']),'LineWidth',1.5)
    
    ylabel('%')
    xlabel('Quarters')
    title(titles{k})
    grid on

    if k == 1
        legend('TAYLOR')
    end

end

