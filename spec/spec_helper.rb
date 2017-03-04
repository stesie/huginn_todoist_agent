def json_response_raw(fixture_name)
  File.read(File.join(__dir__, "/fixtures/#{fixture_name}.json"))
end
