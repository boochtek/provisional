Then /^the output should contain the version number$/ do
  assert_partial_output(Provisional::VERSION, all_output)
end
