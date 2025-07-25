import os
import argparse
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
import numpy as np
import pandas as pd

fontsize = 15
color_map = ["#63C082", "#FB9F5D", '#C09ABE', "#ED7F6F", "#699ED4", "#A9DDAB", "#8DD3C8", "#FBB45D",]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Process some CSV files.')
    parser.add_argument('result_path', type=str, help='The path of experiment result traces')
    parser.add_argument('test_name', type=str, help='The name of the test')
    args = parser.parse_args()

    detail_dir = f'{args.result_path}/{args.test_name}'
    summary_file = f'{args.result_path}/{args.test_name}_summary.csv'
    latency_plot_file = f'{args.result_path}/{args.test_name}_latency.pdf'
    disk_plot_file = f'{args.result_path}/{args.test_name}_disk.pdf'
    
    summary_dict = {"entry_count":[], "version_count":[], "value_size":[], 
                    "throughput":[], "latency":[], "disk":[]}
    detail_files = []
    for entry in os.listdir(detail_dir):
        full_path = os.path.join(detail_dir, entry)
        if os.path.isfile(full_path) and entry.endswith('.csv'):
            fname = full_path.split('/')[-1].split('.')[0]
            fname, vl = fname.split('v')
            vl = int(vl)
            acc, update = fname.split('u')
            acc, update = int(acc.strip('e')), int(update)
            detail_files.append((acc, update, vl, fname, full_path))
    
    plt.figure(figsize=(6, 2))
    detail_files = sorted(detail_files)
    
    for i, (acc, bz, vl, fn, fp) in enumerate(detail_files):
        df = pd.read_csv(fp)
        summary_dict["entry_count"].append(acc)
        summary_dict["version_count"].append(bz)
        summary_dict["value_size"].append(vl)
        summary_dict["throughput"].append(np.mean(df['throughput'].to_numpy()))
        summary_dict["latency"].append(np.mean(df['latency'].to_numpy()))
        summary_dict["disk"].append(df.iloc[-1]['size'])
    summary_df =  pd.DataFrame(summary_dict)
    summary_df.to_csv(summary_file, index=False)
    
    for i, (acc, bz, vl, fn, fp) in enumerate(detail_files):
        df = pd.read_csv(fp)
        plt.plot(df['version'], df['latency'], label=f'data volume={acc}', color=color_map[i])
    plt.ticklabel_format(style='sci', scilimits=(-1,2), axis='y')
    plt.xlabel('#version', fontsize=fontsize)
    plt.ylabel('latency (s)', fontsize=fontsize)
    plt.legend(handlelength=0.5)
    pdf = PdfPages(latency_plot_file)
    pdf.savefig(bbox_inches='tight', transparent=True, dpi=600)
    pdf.close()
    plt.show()
    
    plt.figure(figsize=(4, 3))
    detail_files = sorted(detail_files)
    for i, (acc, bz, vl, fn, fp) in enumerate(detail_files):
        df = pd.read_csv(fp)
        plt.plot(df['version'], df['size']/1000000, label=f'data volume={acc}', color=color_map[i])
    plt.ticklabel_format(style='sci', scilimits=(-1,2), axis='y')
    plt.xlabel('#version', fontsize=fontsize)
    plt.ylabel("Disk usage (MB)", fontsize=fontsize)
    plt.legend(handlelength=0.5)
    pdf = PdfPages(disk_plot_file)
    pdf.savefig(bbox_inches='tight', transparent=True, dpi=600)
    pdf.close()
    plt.show()
    
    
        
        