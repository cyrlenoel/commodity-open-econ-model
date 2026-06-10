policies = {'DIT','CPI','PEG','TAYLOR'};

for k = 1:numel(policies)
    txt = fileread('commodity2.mod');
    txt = regexprep(txt, ...
        '@#define POLICY\s*=\s*".*?"', ...
        ['@#define POLICY = "' policies{k} '"']);

    fid = fopen('commodity2_tmp.mod','w');
    fwrite(fid, txt);
    fclose(fid);

    dynare commodity2_tmp noclearall
    RESULTS.(policies{k}) = oo_;
end

% figure;
% hold on;
% 
% plot(RESULTS.DIT.irfs.pi_eps_ptcstar,'LineWidth',2)
% plot(RESULTS.CPI.irfs.pi_eps_ptcstar,'LineWidth',2)
% plot(RESULTS.PEG.irfs.pi_eps_ptcstar,'LineWidth',2)
% plot(RESULTS.TAYLOR.irfs.pi_eps_ptcstar,'LineWidth',2)
% 
% legend('DIT','CPI','PEG','Taylor')
% xlabel('Quarters')
% ylabel('Percent')
% title('CPI Inflation Response')
% grid on

vars = {'pi','pi_h','y_h','c','n','i','riskprem','e'};
titles = {'CPI inflation', ...
          'Domestic inflation', ...
          'Output', ...
          'Consumption', ...
          'Employment', ...
          'Interest rate', ...
          'Risk premium', ...
          'Nominal exchange rate'};

figure;

for k = 1:length(vars)

    subplot(2,4,k);
    hold on;

    plot(RESULTS.DIT.irfs.([vars{k} '_eps_ptcstar']),'LineWidth',1.5)
    plot(RESULTS.CPI.irfs.([vars{k} '_eps_ptcstar']),'LineWidth',1.5)
    plot(RESULTS.PEG.irfs.([vars{k} '_eps_ptcstar']),'LineWidth',1.5)
    plot(RESULTS.TAYLOR.irfs.([vars{k} '_eps_ptcstar']),'LineWidth',1.5)

    title(titles{k})
    grid on

    if k == 1
        legend('DIT','CPI','PEG','TAYLOR')
    end

end

