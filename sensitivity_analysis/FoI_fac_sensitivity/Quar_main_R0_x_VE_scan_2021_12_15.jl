# main quarantine ABM script

# turning detection off for benchmarking

#used seed = 10 on 2021 08 06

using Distributed

global vaccinated_arrivals_index = 1
global compliance_index = 1
global efficacy_index = 0
global R0_index = 0
global R0s = 1.0:1.0:10.0
global VEs = 0.0:0.1:0.9
global R0 = 0.0
global VE = 0.0
#global test_schedule_index = 1
#global compliance_rate_index = 1

function main()

    include("./Quar_ABM_utils.jl")
    include("./Agent_Quar.jl")
    include("./Quar_ABM_environment.jl")


    #define R0 outside of ABM_disease.. .

    #R0 = R0s[R0_index]
    #VE = 0.0#VEs[efficacy_index]

    include("./Quar_ABM_disease_no_R0.jl")

    #model = AgentBasedModel(agent_type, Space)

    include("./Quar_ABM_functions_2021_08_26.jl")


    date = "2021_12_15"

    output_dirname = pwd() * "\\R0xVE_FoI_fac_10x\\" * date *"\\"
    if !isdir(output_dirname)
     mkpath(output_dirname)
    end


      model_main = AgentBasedModel(agent_type, Space)

      # initialise label for run:
      label = "Run_FoI10x_"

      tag = "R0_$R0"
      tag = replace(tag, "." => "-")
      label = label*tag*"_"

      # vaccination parameters
      pVac_Travellers = 0.0
      if vaccinated_arrivals_index == 1
        pVac_Travellers = 1.0
        #label = label*"VacYES_"
      elseif vaccinated_arrivals_index == 0
        pVac_Travellers = 0.0
        #label = label*"VacNO_"
      end

      #default
      VEi = 0.0
      VEs = 0.0

      # two -dose COMIRNATY (pfizer)
      if vaccinated_arrivals_index == 1

        VEi = 0.0
        VEs = VE
        tag = "VE_$VEs"
        tag = replace(tag, "." => "-")
        label = label*tag*"_"

      #=    if efficacy_index == 1
            VEi = 0.65 # efficacy for infectiousness (i.e., onward transmission)
            VEs = 0.91 # efficacy for susceptibility (i.e., initial infection)
            label = label*"COM2_"
          end
          #2-dose astra zeneca
          if efficacy_index == 2
            VEi = 0.65
            VEs = 0.80
            label = label*"AZ2_"
          end

          #1-dose astra zeneca
          if efficacy_index == 3
            VEi = 0.47 # efficacy for infectiousness (i.e., onward transmission)
            VEs = 0.64 # efficacy for susceptibility
            label = label*"AZ1_"
          end =#
      end

      #default
      quar_duration = 14.0

      if vaccinated_arrivals_index == 1
        quar_duration = 14.0
        #label = label*"tQuar14_"
      elseif vaccinated_arrivals_index == 0
        quar_duration = 14.0
        #label = label*"tQuar14_"
      end


      #default
      test_schedule = [3.0, 12.0]
      if vaccinated_arrivals_index == 1
        test_schedule = [3.0, 12.0]
        #label = label*"T3T12_"
      elseif vaccinated_arrivals_index == 0
        test_schedule = [3.0, 12.0]
        #label = label*"T3T12_"
      end

      # default
      compliance_rate = 1.0
      if vaccinated_arrivals_index == 1
        compliance_rate = 1.0
        #label = label*"C1_"
      elseif vaccinated_arrivals_index == 0
        if compliance_index == 1
          compliance_rate = 1.0
          #label = label*"C1_"
        elseif compliance_index == 99
          compliance_rate = 0.99
          #label = label*"C99_"
        elseif compliance_index == 95
          compliance_rate = 0.95
          #label = label*"C95_"
        end
      end
    #=  if compliance_rate_index == 1
        compliance_rate = 1.0
        label = label*"C1_"
      elseif compliance_rate_index == 2
        compliance_rate = 0.9
        label = label*"C09_"
      elseif compliance_rate_index == 3
        compliance_rate = 0.5
        label = label*"C05_"
      end=#



      hotel_quar_flag = true
      home_quar_flag = false

      if hotel_quar_flag
        quar_env = "Hotel"
      elseif home_quar_flag
        quar_env = "Home"
      else
        quar_env = "unspecified"
      end

      #label = label* quar_env * "_"

      # set up agent properties:
      # test out Space by adding some agents:
      #set up some model parameters:
      n_workers = 20
      n_travellers = 100
      n_travellers_per_household = 4

      pVac_Workers = 1.0

      vaccinated_index_cases_flag = false

      # proportion of incomming travellers infected
      pI_0 = 0.01#0.01#0.01#0.99#0.01;
      pI_Vac = pI_0 * (1 - VEs)

      FoI_fac_Hotel_TT_same = 1.0
      # FoI_fac_Hotel_TT_dif = 0.01
      # FoI_fac_Hotel_TW = 0.01
      # FoI_fac_Hotel_WW = 0.1
      FoI_fac_Hotel_TT_dif = 0.1
      FoI_fac_Hotel_TW = 0.1
      FoI_fac_Hotel_WW = 1.0

      test_schedule_ext = [3.0, 12.0]
      #test_schedule_ext = [Inf, Inf]


      clinical_detection_flag = true

      quar_extension = 14.0
      iso_duration = 10.0

      iso_symptom_extension_flag = false

      # this makes sure groups moved
      home_ext_compliance_rate = 1.0

      #this means contacts of confirmed cases are taken to medi hotel for extension
      medi_hotel_flag = false

      test_report_delay = 1.0

      # select work roster:
      #roster = rosters[1] # everyone works 7 days per week
      roster = rosters[2] # everyone works 5 days per week
      #roster = rosters[3] # some people work 3 days, some work 5
      #roster = rosters[4] # some people work 1 day, some 3 days, and some work 5
      #TODO make sure correct number of workers take days off. not relevant to home quarantine.


      # generate config file for run:
      run_label = "$label" * date
      run_dirname = output_dirname * "\\" * run_label
      println("recording output in file: $run_dirname")
      if !isdir(run_dirname)
        mkdir(run_dirname)
      end
      run_configfile_name = [run_dirname * "\\$label" * "_config.txt"]

      write_config_file(join(run_configfile_name),
          R0,
          tf,
          dt,
          t_burn,
          pI_0,
          pI_Vac,
          quar_duration,
          quar_extension,
          iso_duration,
          quar_env,
          medi_hotel_flag,
          test_schedule,
          test_schedule_ext,
          test_report_delay,
          clinical_detection_flag,
          n_travellers_per_household,
          n_travellers,
          n_workers,
          roster,
          compliance_rate,
          pVac_Workers,
          pVac_Travellers,
          vaccinated_index_cases_flag,
          VEs,
          VEi,
          FoI_fac_Hotel_TT_same,
          FoI_fac_Hotel_TT_dif,
          FoI_fac_Hotel_TW,
          FoI_fac_Hotel_WW)


      #t_sens = []
      #i_check = []

      initialise_agents!(n_travellers, n_workers, model_main, environments)

      # check work schedule
      n_min = 5 # need a schedule with at least 5 workers present each day
      global work_schedule_OK = false;
      global trys = 0
      while !work_schedule_OK
        initialise_work_schedule!(model_main, environments, roster)
        global trys += 1 # julia while loop weirdness....
        global work_schedule_OK = check_work_schedule(model_main, n_min)
        if trys > 1000
          println("having trouble assigning minimum number of workers each day - adjust roster or number of workers")
          return
        end
      end

      # vaccinate agents - can swap this around with infection algorithm if desired.
      vaccinate_all!(model_main, pVac_Workers, pVac_Travellers)

      # assign household IDs to travellers

      assign_households!(model_main, n_travellers_per_household, households )
      # removal from memory occurs on a household basis. household groups are removed and replaced together.
      # note: removal is distinct from discharge - if members of a household are in iso,
      # the rest of the family can enter the community while waiting for them.


      # infect arrivals -
      # anyone in the arrivals node can become infected - remember to move them out
      # of arrivals node after evaluating infection status...
      infect_arrivals!(model_main, pI_0, pI_Vac)

      if vaccinated_index_cases_flag
        vaccinate_infected_arrivals!(model_main)
      end


      assign_compliance_rate_to_arrivals!(model_main, compliance_rate)

      # move arrivals into quarantine
      if hotel_quar_flag
        move_arrivals_to_hotel_quarantine!(model_main, test_schedule)
      elseif home_quar_flag
        move_arrivals_to_home_quarantine!(model_main, test_schedule)
      end
      #move_arrivals_to_hotel_quarantine!(model, test_schedule)


      # begin iterating through time.
      # infect a worker and see if testing works:
      #infect_agent!(model[1])

      global n_travellers_discharged = 0.0
      global n_infected_arrivals = 0.0


      #build weekly data vectors
      travellers_discharged_weekly = []
      infectious_travellers_dischaged_weekly = []
      secondary_cases_weekly = []
      exposure_days_T_weekly = []
      exposure_days_T_uv_weekly = []
      exposure_days_T_vac_weekly = []
      exposure_days_W_weekly = []
      exposure_days_W_uv_weekly = []
      exposure_days_W_vac_weekly = []
      infected_arrivals_uv_weekly = []
      infected_arrivals_vac_weekly = []
      PCR_detections_weekly = []
      clinical_detections_weekly = []

      travellers_discharged_this_week = 0.0
      infectious_travellers_dischaged_this_week = 0.0
      secondary_cases_this_week = 0.0
      exposure_days_T_this_week = 0.0
      exposure_days_T_uv_this_week = 0.0
      exposure_days_T_vac_this_week = 0.0
      exposure_days_W_this_week = 0.0
      exposure_days_W_uv_this_week = 0.0
      exposure_days_W_vac_this_week = 0.0
      infected_arrivals_uv_this_week = 0.0
      infected_arrivals_vac_this_week = 0.0
      PCR_detections_this_week = 0.0
      clinical_detections_this_week = 0.0


      time_increment = copy(dt)

      for t in 1.0:time_increment:tf

          if mod(t, 1000) == 0
            println(t)
          end

          if mod(t, 1) == 0
            #initialise output summary tallies for the first week:

            # record weekly summary data
            if mod(t, 7) == 0
              if t > t_burn
                #println("recording at time $t, $(mod(t, 7))")
                push!(travellers_discharged_weekly, travellers_discharged_this_week)
                push!(infectious_travellers_dischaged_weekly, infectious_travellers_dischaged_this_week)
                push!(secondary_cases_weekly, secondary_cases_this_week)
                push!(exposure_days_T_weekly, exposure_days_T_this_week)
                push!(exposure_days_T_uv_weekly, exposure_days_T_uv_this_week)
                push!(exposure_days_T_vac_weekly, exposure_days_T_vac_this_week)
                push!(exposure_days_W_weekly, exposure_days_W_this_week)
                push!(exposure_days_W_uv_weekly, exposure_days_W_uv_this_week)
                push!(exposure_days_W_vac_weekly, exposure_days_W_vac_this_week)
                push!(infected_arrivals_uv_weekly, infected_arrivals_uv_this_week)
                push!(infected_arrivals_vac_weekly, infected_arrivals_vac_this_week)
                push!(PCR_detections_weekly, PCR_detections_this_week)
                push!(clinical_detections_weekly, clinical_detections_this_week)

                travellers_discharged_this_week = 0.0
                infectious_travellers_dischaged_this_week = 0.0
                secondary_cases_this_week = 0.0
                exposure_days_T_this_week = 0.0
                exposure_days_T_uv_this_week = 0.0
                exposure_days_T_vac_this_week = 0.0
                exposure_days_W_this_week = 0.0
                exposure_days_W_uv_this_week = 0.0
                exposure_days_W_vac_this_week = 0.0
                infected_arrivals_uv_this_week = 0.0
                infected_arrivals_vac_this_week = 0.0
                PCR_detections_this_week = 0.0
                clinical_detections_this_week = 0.0
              end
            end
          end


          n_workers_present = convert(Float64, n_workers)
          # check to see if it's a new day:
          if mod(t, 1) == 0
            #println(length(households))
            # 1) the workforce for the day is determined,
            local day_of_week = mod(t, 7)
            n_workers_present = assign_workforce!(model_main, day_of_week)
            #2) the workforce present is tested
            test_workforce!(model_main, test_report_delay)
            # 3) test results for workers previously tested are returned and evaluated
            evaluate_workforce_tests!(model_main)
            # 4) positive tests or onset of symptoms in workers cause them to be 'discharged'
            # 5) a discharged worker is replaced with a new, susceptible worker with the same schedule
            discharge_workers!(model_main, t, pVac_Workers, p_asymp)

            #6) test results are returned for travellers previously tested
            evaluate_traveller_tests!(model_main)
            # 7) travellers who test positive or recently became symptomatic are put into isolation
            # 8) contacts of travellers who test positive are put into extension (if they're not already there)

            PCR_detections_t,
            clinical_detections_t =
            isolate_travellers!(model_main, iso_duration, test_schedule_ext, medi_hotel_flag, home_ext_compliance_rate)

            PCR_detections_this_week += PCR_detections_t
            clinical_detections_this_week += clinical_detections_t
            # 9) all travellers who are finished with quarantine are discharged into the community

            n_households_to_add = [0]
            n_agents_to_add = [0]

            n_discharged, n_discharged_infected = discharge_travellers!(model_main, t, n_households_to_add, n_agents_to_add)
            # 10) once all members of a household are discharged, a new household is added to the arrivals node
            travellers_discharged_this_week += n_discharged
            infectious_travellers_dischaged_this_week += n_discharged_infected

            # new arrivals are initialised (vaccine and infection status is determined)
            n_infected_arrivals_t,
            n_infected_arrivals_uv_t,
            n_infected_arrivals_vac_t =
            initialise_arrivals!(model_main, pVac_Travellers, pI_Vac, pI_0, n_households_to_add[1], n_agents_to_add[1], test_schedule)

            #=if n_infected_arrivals_t > 0.1
             println("infected arrivals: $n_infected_arrivals_t")
           end=#

            infected_arrivals_uv_this_week += n_infected_arrivals_uv_t
            infected_arrivals_vac_this_week += n_infected_arrivals_vac_t

            #=if n_infected_arrivals_t > 0.1
             println("infected arrivals this week: $infected_arrivals_uv_this_week")
           end=#


            # makes sure all index cases are vaccinated.
            if vaccinated_index_cases_flag
              vaccinate_infected_arrivals!(model_main)
            end
            assign_compliance_rate_to_arrivals!(model_main, compliance_rate)

            # the below functions can be modified to move conditional on agent properties
            if hotel_quar_flag
              move_arrivals_to_hotel_quarantine!(model_main, test_schedule)
            elseif home_quar_flag
              move_arrivals_to_home_quarantine!(model_main, test_schedule)
            end

            # once all individuals in a household are in the community and recovered,
            # they are removed from the model. NOTE: the delete! function can be used delete
            # the specified households from the households dict. and the kill_agent! function
            # can be used to remove the agents from the model.

            record_and_delete!(model_main)

            test_travellers!(model_main, test_report_delay)

            #println(t)
            #check_test_sensitivity!(model, t_sens, i_check)

            evaluate_compliance!(model_main)

          end

          # TODO: compute transmission for different contact management policies

          secondary_cases_t = compute_transmission!(model_main,
                                                    VEi,
                                                    VEs,
                                                    FoI_fac_Hotel_TT_same,
                                                    FoI_fac_Hotel_TT_dif,
                                                    FoI_fac_Hotel_TW,
                                                    FoI_fac_Hotel_WW,
                                                    n_workers_present,
                                                    time_increment)

          secondary_cases_this_week += secondary_cases_t

          # step clocks and update states:
          edays_W_t,
          edays_uv_W_t,
          edays_vac_W_t = step_workers!(model_main, time_increment)

          exposure_days_W_this_week += edays_W_t
          exposure_days_W_uv_this_week += edays_uv_W_t
          exposure_days_W_vac_this_week += edays_vac_W_t



          edays_T_t,
          edays_uv_T_t,
          edays_vac_T_t = step_travellers!(model_main,
                                           quar_duration,
                                           quar_extension,
                                           iso_duration,
                                           time_increment)

         exposure_days_T_this_week += edays_T_t
         exposure_days_T_uv_this_week += edays_uv_T_t
         exposure_days_T_vac_this_week += edays_vac_T_t


        if clinical_detection_flag
          assess_symptoms!(model_main, iso_duration, iso_symptom_extension_flag)
        end

        #  check_agents!(model)


      end

      output_filename_T = run_dirname * "\\Traveller_breach.csv"
      output_filename_W = run_dirname * "\\Worker_breach.csv"

      breach_T = linelist_T[linelist_T.exposure_days .!= 0, :]
      breach_W = linelist_W

      CSV.write(output_filename_T, breach_T)
      CSV.write(output_filename_W, breach_W)

      #println("discharged $n_travellers_discharged travellers" )
      #println("infected arrivals: $n_infected_arrivals" )

      #output_filename_tsens = output_dirname * "\\tsens.csv"
      #CSV.write(output_filename_tsens, DataFrame(temp_ = t_sens))

      # weekly averages:

      w1_stst = convert(Int64, ceil(t_burn / 7))

      travellers_discharged_pw = mean(travellers_discharged_weekly[w1_stst:end])
      I_travellers_discharged_pw = mean(infectious_travellers_dischaged_weekly[w1_stst:end])
      secondary_cases_pw = mean(secondary_cases_weekly[w1_stst:end])
      edays_pw_T = mean(exposure_days_T_weekly[w1_stst:end])
      edays_pw_T_uv = mean(exposure_days_T_uv_weekly[w1_stst:end])
      edays_pw_T_vac = mean(exposure_days_T_vac_weekly[w1_stst:end])
      edays_pw_W = mean(exposure_days_W_weekly[w1_stst:end])
      edays_pw_W_uv = mean(exposure_days_W_uv_weekly[w1_stst:end])
      edays_pw_W_vac = mean(exposure_days_W_vac_weekly[w1_stst:end])
      infected_arrivals_pw_uvac = mean(infected_arrivals_uv_weekly[w1_stst:end])
      infected_arrivals_pw_vac = mean(infected_arrivals_vac_weekly[w1_stst:end])
      detections_pw_tests = mean(PCR_detections_weekly[w1_stst:end])
      detections_pw_clin = mean(clinical_detections_weekly[w1_stst:end])

      edays_per_inf_arrival_T = edays_pw_T / (infected_arrivals_pw_uvac + infected_arrivals_pw_vac)
      edays_per_inf_arrival_W = edays_pw_W / (infected_arrivals_pw_uvac + infected_arrivals_pw_vac)

      # generate results summary file for run:

      results_summary_filename = join([run_dirname * "\\$label" * "_summary.txt"])

      write_output_summary(
        results_summary_filename,
        edays_pw_T,
        edays_pw_T_uv,
        edays_pw_T_vac,
        edays_pw_W,
        edays_pw_W_uv,
        edays_pw_W_vac,
        edays_per_inf_arrival_T,
        edays_per_inf_arrival_W,
        infected_arrivals_pw_uvac,
        infected_arrivals_pw_vac,
        detections_pw_tests,
        detections_pw_clin,
        travellers_discharged_pw,
        I_travellers_discharged_pw,
        secondary_cases_pw)

end

  for r_i in 1:size(R0s, 1)#, 0]#, 2]
    for e_i in 1:size(VEs, 1)
      #for c_i in [1]#[95]#[99]
      #for t_i in [1]#, 2, 3]

            global R0_index = r_i
            global efficacy_index = e_i
            global R0 = R0s[R0_index]
            global VE = VEs[efficacy_index]
            #global compliance_index = c_i
            #global test_schedule_index = t_i
            #global compliance_rate_index = c_i

            main()


        #end
      #end
    end
  end




# every day, the following events happen:
# 1) the workforce for the day is determined,
# 2) the workforce present is tested
# 3) test results for workers previously tested are returned and evaluated
# 4) positive tests or onset of symptoms in workers cause them to be 'discharged'
# 5) a discharged worker is replaced with a new, susceptible worker with the same schedule

# 6) test results are returned for travellers previously tested
# 7) travellers who test positive or recently became symptomatic are put into isolation
# 8) contacts of travellers who test positive are put into extension (if they're not already there)
# 9) all travellers who are finished with quarantine are discharged into the community
# 10) once all members of a household are discharged, a new household is added in the 'arrivals' node and initialised
    # once all members of a discharged household are recovered, they are tabulated into the line list and removed from memory
# 12) infection and vaccination status of new arrivals is evaluated and they are moved into quarantine
      # optionally, this can be handled by the 'step travellers' function
# 13) all travellers scheduled for testing are tested (results returned after specified delay)
      # note - test sensitivity is evaluated based on infection clock and individual-level parameters

# every timestep, the following events happen:
# 12) iterate through the occupied nodes of the graph and compute pair-wise transmission between contacts
# 13) step all clocks
# TODO decide whether symptomatic agents should be isolated immediately, or on the following day
