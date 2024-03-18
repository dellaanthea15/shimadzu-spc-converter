require 'csv'
require_relative 'spc_file.rb'

spc = SpcFile.new(ARGV[0])

basename = File.basename(ARGV[0], '.*')
dir = File.dirname(ARGV[0])

root = spc.get_dir(0)
spc.search_sibs(spc.get_dir(root[:child_id]), /DataStorage[0-9]+/).each do |ds|
  dsg = spc.search_path(ds, ['DataSetGroup'])
  datasets = spc.search_sibs(spc.get_dir(dsg[:child_id]), /DataSet[0-9]+/)

  datasets.each do |dataset|
    xdata = spc.search_path(dataset, ['DataSpectrumStorage', 'Data', 'X Data.1'])
    ydata = spc.search_path(dataset, ['DataSpectrumStorage', 'Data', 'Y Data.1'])

    xvals = spc.read_stream(xdata[:sid], xdata[:size]).unpack('d*')
    yvals = spc.read_stream(ydata[:sid], ydata[:size]).unpack('d*')

    fname = File.join(dir, "#{basename}_#{ds[:name]}_#{dataset[:name]}.csv")
    puts fname
    CSV.open(fname, 'wb') do |csv|
      csv << ['wl', 'abs']
      xvals.zip(yvals).each do |row|
        csv << row
      end
    end
  end
end
