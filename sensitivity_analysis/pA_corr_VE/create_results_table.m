
date_tag = '2021_12_16'
    
    
    %path to the results directory:
    base_dirname = [pwd() '\R0xVE_pA_corr_VE\' date_tag '\']
    
    %output_filename = [base_dirname, 'output_table_R0xVE_scan_H14_tf400k.csv']
    
    output_filename = [base_dirname, 'output_t_relbase_R0xVE_pAVEcorr.csv']
    
    VEs = 0.0:0.1:0.9
    R0s = 1.0:10.0
    
    VE = NaN(numel(VEs)*numel(R0s), 1)
    R0 = NaN(numel(R0s)*numel(R0s), 1)
    
    n_breach = NaN(numel(R0s)*numel(R0s), 1)
    net_FoI = NaN(numel(R0s)*numel(R0s), 1)
    net_FoI_maxVE = NaN(numel(R0s)*numel(R0s), 1)
    net_FoI_rel_base = NaN(numel(R0s)*numel(R0s), 1)
    net_FoI_maxVE_rel_base = NaN(numel(R0s)*numel(R0s), 1)
    net_exp_days = NaN(numel(R0s)*numel(R0s), 1)
    
    breach_per_IA = NaN(numel(R0s)*numel(R0s), 1)
    FoI_per_IA = NaN(numel(R0s)*numel(R0s), 1)
    exp_days_per_IA = NaN(numel(R0s)*numel(R0s), 1)
    
    n_weeks = 1000000/7
    t_burn = 1000
    
    
    baseline_dirname = ['C:\Users\czachreson\Desktop\compositions_in_progress',...
                       '\Quarantine_modelling\model\julia_version_full',...
                       '\parameter_scan\fixed_worker_count\',...
                       'R0_x_VE_scan_H14_tf_1M\baseline_Run_R0_3-0_VE_0-0_2021_08_26\'];
                   
    baseline_T = readtable([baseline_dirname 'Traveller_breach.csv']);
    baseline_W = readtable([baseline_dirname 'Worker_breach.csv']);
    
    Trav_list = baseline_T(baseline_T.time_discharged > t_burn, :);
    Wrk_list = baseline_W(baseline_W.time_discharged > t_burn, :);
    
    baseline_net_FoI = sum(Trav_list.FoI_community) + sum(Wrk_list.FoI_community);
    
    
    
    i = 0
    for r_i = 1:numel(R0s)
        
        for v_i = 1:numel(VEs)
            
            i = i + 1;
            
            VE(i, 1) = VEs(v_i);
            R0(i, 1) = R0s(r_i);
            
            VE_tag = strrep(num2str(VEs(v_i), '%2.1f'), '.', '-');
            R0_tag = strrep(num2str(R0s(r_i), '%2.1f'), '.', '-');
            
            run_tag = ['Run_R0_', R0_tag, '_VE_' VE_tag];
            
            
            run_dirname = [base_dirname, run_tag, '_', date_tag, '\'];
            
            traveller_breach_filename = ...
                [run_dirname, 'Traveller_breach.csv'];
            
            worker_breach_filename = ...
                [run_dirname, 'Worker_breach.csv'];
            
            summary_filename = ...
                [run_dirname, run_tag, '__summary.txt'];
            
            Trav_list = readtable(traveller_breach_filename);
            Wrk_list = readtable(worker_breach_filename);
            
            fid = fopen(summary_filename);
            output_summary = textscan(fid, '%s', 'delimiter', '\n');
            output_summary = output_summary{1, 1};
            
            I_in_per_week = output_summary{21};
            sep_ind = strfind(I_in_per_week, ': ');
            I_in_per_week = I_in_per_week(sep_ind+2:end-1);
            I_in_per_week = str2double(I_in_per_week);
            
            n_infected_arrivals = I_in_per_week * n_weeks;
            
            Trav_list = Trav_list(Trav_list.time_discharged > t_burn, :);
            Wrk_list = Wrk_list(Wrk_list.time_discharged > t_burn, :);
            
            FoI_net = sum(Trav_list.FoI_community) + sum(Wrk_list.FoI_community);
            
            FoI_net_rel_base = FoI_net / baseline_net_FoI;
            
            FoI_net_maxVEt = FoI_net * (1 - VE(i, 1));
            
            FoI_net_maxVEt_rel_base = FoI_net_maxVEt / baseline_net_FoI;
            
            n_breach_i = size(Trav_list, 1) + size(Wrk_list, 1);
            exp_days_tot = sum(Trav_list.exposure_days) + sum(Wrk_list.exposure_days);
            
            net_FoI_maxVE(i, 1) = FoI_net_maxVEt;
            
            n_breach(i, 1) = n_breach_i;
            net_FoI(i, 1) = FoI_net;
            net_exp_days(i, 1) = exp_days_tot;
            
            net_FoI_rel_base(i, 1) = FoI_net_rel_base;
            net_FoI_maxVE_rel_base(i, 1) = FoI_net_maxVEt_rel_base;
            
            breach_per_IA(i, 1) = net_exp_days(i) / n_infected_arrivals;
            FoI_per_IA(i, 1) = FoI_net / n_infected_arrivals;
            exp_days_per_IA(i, 1) = exp_days_tot / n_infected_arrivals;
            
            
        end
        
    end
    
    output_table = table(R0, VE, n_breach, net_FoI, net_FoI_maxVE, net_exp_days, breach_per_IA, FoI_per_IA, exp_days_per_IA, net_FoI_rel_base, net_FoI_maxVE_rel_base  );
    writetable(output_table, output_filename)
    
