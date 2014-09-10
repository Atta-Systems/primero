require 'spec_helper'
require 'spreadsheet'

module Exporters
  describe ExcelExporter do
    it "converts data to Excel format" do
      BaseExporter.should_receive(:to_2D_array)
        .and_yield([ 'name', 'age', 'birthday', 'height' ])
        .and_yield([ 'Joe', 12, Date.today, 120 ])
        .and_yield([ 'Mo', 14, Date.today, 140 ])

      data = ExcelExporter.export(nil, nil)

      book = Spreadsheet.open(StringIO.new(data))
      sheet = book.worksheets[0]
      sheet.row(1)[2].should == Date.today.to_s
      sheet.row(0).to_a.should == ['name', 'age', 'birthday', 'height']
    end
  end
end
