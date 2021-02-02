require_relative 'auto-seg'

s = '當觀色無常。如是觀者，則為正觀。正觀者，則生厭離；厭離者，喜貪盡；喜貪盡者，說心解脫。'
puts AutoSeg.new.run(s)