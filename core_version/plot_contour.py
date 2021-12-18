# -*- coding: utf-8 -*-
"""
Created on Thu Jul  1 15:22:41 2021

@author: czachreson
"""

import matplotlib.pyplot as plt
import numpy as np
import seaborn as sns
import pandas as pd
sns.set_theme()

# Load the example flights dataset and convert to long-form
#flights_long = sns.load_dataset("flights")
#flights = flights_long.pivot("month", "year", "passengers")

# Draw a heatmap with the numeric values in each cell
#f, ax = plt.subplots(figsize=(9, 6))
#sns.heatmap(flights, annot=True, fmt="d", linewidths=.5, ax=ax)

#input_dirname = "C:\\Users\\czachreson\\Desktop\\compositions_in_progress\\Quarantine_modelling\\model\\julia_version_full\\Delta_variant\\R0_x_VE_H14_tinc4p4_tf_1M\\2021_08_17\\"

input_dirname = "C:\\Users\\czachreson\\Desktop\\compositions_in_progress\\Quarantine_modelling\model\\julia_version_full\\parameter_scan\\fixed_worker_count\\R0_x_VE_scan_H14_tf_1M\\2021_08_26\\"

#label = "R0xVE_scan_H14_tf400k"
#label = "R0xVE_scan_H14_tf_1M"
label = "output_t_relbase_R0xVE_scan_H14_tf_1M"

#value_plotted = "FoI_per_IA"
#value_plotted = "net_exp_days"
#value_plotted = "exp_days_per_IA"
#value_plotted = "net_FoI"
#value_plotted = "net_FoI_maxVE"
#value_plotted = "net_FoI_rel_base"

value_plotted = "net_FoI_maxVE_rel_base"

heatmap_filename = input_dirname  + label + ".csv"

figname = input_dirname + label + "_hmap_overlay_" + value_plotted + ".pdf"

risk_VE_x_R0 = pd.read_csv(heatmap_filename)
hmap_square = risk_VE_x_R0.pivot("VE", "R0", value_plotted)

hmap_invert = hmap_square.iloc[::-1]

f1, ax1 = plt.subplots(figsize=(16, 9))

#plt.contour(hmap_square.columns, hmap_square.index, hmap_square)

sns.heatmap(hmap_invert, annot=True, fmt='.3g', linewidths=.5, ax=ax1, cmap="hot")


cols_scaled = hmap_square.columns - 0.5
rows_scaled = 10 - hmap_square.index * 10 - 0.5

plt.contour(cols_scaled, rows_scaled, hmap_square, colors='cyan', linewidths=2)           
#plt.contour(hmap_square.columns, hmap_square.index, hmap_square)
# hom_scaled = pd.read_csv(threshold_filename)
# hom_scaled.c_hom = (hom_scaled.c_hom-0.4) * 5 + 0.5
# hom_scaled.Vei_hom = 4 - hom_scaled.Vei_hom * 4 + 0.5


# sns.lineplot(data=hom_scaled, x="c_hom", y="Vei_hom", ax=ax1, legend=True )
# ax1.lines[0].set_linestyle("--")
# ax1.lines[0].set_color("black")
# ax1.legend(['Herd immunity threshold (homogeneous approximation)'], loc='best',
#            bbox_to_anchor = (-4,0.13,5,1))

ax1.set_xlabel("$R_0$", size = 25)
ax1.set_ylabel("VE", size = 25)
ax1.collections[0].colorbar.set_label(r'$\beta_{tot}~/~$baseline', rotation = 270, labelpad = 40, size=25)


f1.savefig(figname)