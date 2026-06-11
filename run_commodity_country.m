% Set policy to TAYLOR
txt = fileread('commodity2.mod');
txt = regexprep(txt, ...
    '@#define POLICY\s*=\s*".*?"', ...
    '@#define POLICY = "TAYLOR"');

fid = fopen('commodity2_tmp.mod', 'w');
fwrite(fid, txt);
fclose(fid);

countries = {'AE','EM'};

for k = 1:numel(countries)
    txt = fileread('commodity2_tmp.mod');
    txt = regexprep(txt, ...
        '@#define COUNTRY\s*=\s*".*?"', ...
        ['@#define COUNTRY = "' countries{k} '"']);

    fid = fopen('commodity2_tmp2.mod','w');
    fwrite(fid, txt);
    fclose(fid);

    dynare commodity2_tmp2 noclearall
    RESULTS.(countries{k}) = oo_;
end

vars = {'pi','pi_h','y_h','c','c_h_star','n','wr','i','e','s','p_tildec'};
titles = {'CPI inflation', ...
          'Domestic inflation', ...
          'Output', ...
          'Consumption', ...
          'Exports', ...
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

    plot(scale*RESULTS.AE.irfs.([vars{k} '_eps_ptcstar']),'LineWidth',1.5)
    plot(scale*RESULTS.EM.irfs.([vars{k} '_eps_ptcstar']),'LineWidth',1.5)
    
    ylabel('%')
    title(titles{k})
    grid on

    if k == 1
        legend('AE','EM')
    end

end

