require "petit"
require "spec_helper"

describe Shortcode do
	
	#be sure there is a configuration to access.
	Petit.configure

	it "does not have ssl by default" do
		expect(subject.ssl?).to be false
	end

	context "instantiated with initializer" do
		let(:shortcode) { Shortcode.new({name: 'ABC123', destination: 'wWw.Google.cOm', ssl: true}) }
		
		it "downcases the shortcode" do
			expect(shortcode.name).to eq("abc123")
		end

		it "downcases the destination" do
			expect(shortcode.destination).to eq('www.google.com')
		end

		it "can set shortcode" do
			expect { shortcode.name = '123ABC' }.to change { shortcode.name }.from('abc123').to('123abc')
		end

		it "can set destination" do
			expect { shortcode.destination  = 'www.YAHOO.com' }.to change { shortcode.destination}.from('www.google.com').to('www.yahoo.com')
		end

		it "can set ssl" do
			expect { shortcode.ssl = false }.to change { shortcode.ssl }.from(true).to(false)
		end

		it "created_at is nil" do
			expect(shortcode.created_at).to be_nil
		end

		it "updated_at is nil" do
			expect(shortcode.updated_at).to be_nil
		end

		it "access_count is nil" do
			expect(shortcode.access_count).to be_nil
		end
	end

	it { is_expected.to respond_to(:save) }

	describe "#save" do
		context "it validates input" do
			it "raises exception when name and destination are not present" do
				shortcode = Shortcode.new()
				expect{shortcode.save}.to raise_exception(ShortcodeErrors::IncompleteObjectError)
			end
			it "raises exception when name is not present" do
				shortcode = Shortcode.new({destination: 'hasdestination'})
				expect{shortcode.save}.to raise_exception(ShortcodeErrors::IncompleteObjectError)
			end
			it "raises exception when destination is not present" do
				shortcode = Shortcode.new({name: 'hasname'})
				expect{shortcode.save}.to raise_exception(ShortcodeErrors::IncompleteObjectError)
			end
		end
		context "when save is successful" do
			shortcode = Shortcode.new({name: 'testshortcodesuccessful', destination: 'www.test.me', ssl: true})
			
			# it can't be successful if it exists already.
			shortcode.destroy
			resp = shortcode.save

			it "returns true" do
				expect(resp).to be true
			end
			it "created_at is an integer" do
				expect(shortcode.created_at).to be_an(Integer)
			end 
			it "updated_at is an integer" do
				expect(shortcode.updated_at).to be_an(Integer)
			end
			it "access_count is zero" do
				expect(shortcode.access_count).to be(0)
			end

			found = Shortcode.find('testshortcodesuccessful')
			it "record should be found in the database" do
				expect(found).to_not be_nil
			end

			context "it is found in the database" do
				it "should match name" do
					expect(found.name).to eq(shortcode.name)
				end
				it "should match destination" do
					expect(found.destination).to eq(shortcode.destination)
				end
				it "should match ssl" do
					expect(found.ssl).to eq(shortcode.ssl)
				end

				it "created_at should be a Time object" do
					expect(found.created_at).to be_a(Time)
				end	

				it "update_at should be a Time object" do
					expect(found.updated_at).to be_a(Time)
				end	

				it "created_at and updated_at should match" do
					expect(found.updated_at).to eq(found.created_at)
				end

				it "should have access_count" do
					expect(found.access_count).to_not be_nil
				end
			end

		end
		context "when shortcode already exists" do
			shortcode = Shortcode.new({name: 'testshortcodeunsuccessful', destination: 'www.test.me', ssl: true})
			it "raises ShortcodeAlreadyExists error" do
				expect {shortcode.save}.to raise_exception(ShortcodeErrors::ShortcodeAccessError)
			end
		end
	end

	it { is_expected.to respond_to(:update) }
	describe "#update" do
		context "is successful" do
			shortcode = Shortcode.new({name: 'testupdateshortcodesuccessful', destination: 'www.test.me', ssl: true})

			# it can't be successful if it exists already.
			shortcode.destroy
			shortcode.save
			shortcode.destination = 'www.test2.me'
			shortcode.ssl = false
			resp = shortcode.update
			it "returns a hash" do
				expect(resp).to be_a(Hash)
			end
			context "returns matching attributes" do
				it "matches name" do
					expect(resp['shortcode']).to eq(shortcode.name)
				end
				it "matches destination" do
					expect(resp['destination']).to eq(shortcode.destination)
				end
				it "matches ssl" do
					expect(resp['ssl']).to eq(shortcode.ssl)
				end
				it "matches created_at" do
					expect(resp['created_at']).to eq(shortcode.created_at)
				end
				it "matches updated_at" do
					expect(resp['updated_at']).to eq(shortcode.updated_at)
				end
				it "matches access_count" do
					expect(resp['access_count']).to eq(shortcode.access_count)
				end
			end
		end
		context "is unsuccessful" do
			context "when shortcode doesn't exist" do
				shortcode = Shortcode.new({name: 'testupdateshortcodeunsuccessful2342523', destination: 'www.test.me', ssl: true})
				it "raises ShortcodeDoesNotExist error" do
					expect {shortcode.update}.to raise_exception(ShortcodeErrors::ShortcodeAccessError)
				end
			end
			context "when improper values are passed" do
				shortcode = Shortcode.new({name: 'testupdateshortcodebadvalues', destination: 'www.test.me', ssl: true})
				shortcode.destroy
				shortcode.save
				
				it "raises IncompleteObjectError when missing name and destination" do
					shortcode.name = nil
					shortcode.destination = nil
					expect {shortcode.update}.to raise_exception(ShortcodeErrors::IncompleteObjectError)
				end

				it "raises IncompleteObjectError when missing name" do
					shortcode.name = nil
					shortcode.destination = "www.newdest.com"
					expect {shortcode.update}.to raise_exception(ShortcodeErrors::IncompleteObjectError)
				end

				it "raises IncompleteObjectError when missing destination" do
					shortcode.name = 'testupdateshortcodebadvalues'
					shortcode.destination = nil
					expect {shortcode.update}.to raise_exception(ShortcodeErrors::IncompleteObjectError)
				end
			end
		end
	end

	it { is_expected.to respond_to(:destroy)}
	describe "#destroy" do
		context "when destroy is successful" do
			it "returns a hash" do
				shortcode = Shortcode.new({name: 'tobedestroyedsuccessful', destination: 'www.destroy.me', ssl: false})
				shortcode.destroy
				shortcode.save
				expect(shortcode.destroy).to be_a(Hash)
			end
		end
		context "when destroy is unsuccessful" do
			let(:shortcode) { Shortcode.new({name: 'tobedestroyedunsuccessful', destination: 'www.destroy.me', ssl: false}) }
			it "returns nil" do
				expect(shortcode.destroy).to be_nil
			end
		end
	end

	it "should respond to find" do
		expect(Shortcode).to respond_to(:find)
	end

	describe ".find" do
		context "when a record is found" do
			shortcode_to_find = Shortcode.new({name: 'tobefound', destination: 'www.find.me', ssl: true})
			shortcode_to_find.destroy
			shortcode_to_find.save
			shortcode = Shortcode.find('tobefound')

			it "is a Shortcode object" do
				expect(shortcode).to be_a(Shortcode)
			end

			it "its name should not be nil" do
				expect(shortcode.name).to_not be_nil
			end

			it "its destination should not be nil" do
				expect(shortcode.destination).to_not be_nil
			end

			shortcode_to_find.destroy
		end
		context "when a record is not found" do
			it "should return nil" do
				shortcode = Shortcode.find('balderdash231312412')
				expect(shortcode).to be_nil
			end
		end
	end

	describe ".find_by_name" do
		it "returns the same thing as .find" do
			shortcode_to_find = Shortcode.new({name: 'tobefound', destination: 'www.find.me', ssl: true})
			shortcode_to_find.destroy
			shortcode_to_find.save
			shortcode_by_find = Shortcode.find('tobefound')
			shortcode_by_find_by_name = Shortcode.find_by_name('tobefound')
			expect(shortcode_by_find.name).to eq(shortcode_by_find_by_name.name)
		end
	end

	describe ".find_by_destination" do
		it "returns an array" do
			destinations = Shortcode.find_by_destination("www.alksdfljasdfhasldhflkadsf.com")
			expect(destinations).to be_a(Array)
		end
		context "when records are found" do
			it "returns an array with one or more records" do
				shortcode1 = Shortcode.new({name: "dest1", destination: "www.dest.go"})
				shortcode2 = Shortcode.new({name: "dest2", destination: "www.dest.go"})
				shortcode1.destroy
				shortcode2.destroy
				shortcode1.save
				shortcode2.save
				destinations = Shortcode.find_by_destination("www.dest.go")
				expect(destinations.length).to be(2)
			end
			it "returns an array of Shortcode objects" do
				shortcode1 = Shortcode.new({name: "dest1", destination: "www.dest.go"})
				shortcode2 = Shortcode.new({name: "dest2", destination: "www.dest.go"})
				shortcode1.destroy
				shortcode2.destroy
				shortcode1.save
				shortcode2.save
				destinations = Shortcode.find_by_destination("www.dest.go")
				expect(destinations[0]).to be_a(Shortcode)
				expect(destinations[1]).to be_a(Shortcode)
			end
		end
		context "when records are not found" do
			it "returns an empty array" do
				destinations = Shortcode.find_by_destination("www.alksdfljasdfhasldhflkadsf.com")
				expect(destinations).to be_empty
			end
		end
	end

	describe "#hit" do
		context "on success" do
			it "increments the counter" do
			  shortcode = Shortcode.new({name: 'toincrement', destination:'www.increment.me'})
			  shortcode.destroy
			  shortcode.save
			  expect{shortcode.hit}.to change { shortcode.access_count }.from(0).to(1)
			end
			it "returns true" do
			  shortcode = Shortcode.new({name: 'toincrement', destination:'www.increment.me'})
			  shortcode.destroy
			  shortcode.save
			  resp = shortcode.hit
			  expect(resp).to be true
			end
		end

		context "on failure" do
			it "does nothing when the shortcode doesn't exist" do
			  shortcode = Shortcode.new({name: 'tonotincrement', destination:'www.donotincrement.me'})
			  shortcode.destroy
			  expect{shortcode.hit}.to_not change { shortcode.access_count }
			end
			it "returns false" do
			  shortcode = Shortcode.new({name: 'tonotincrement', destination:'www.donotincrement.me'})
			  shortcode.destroy
			  resp = shortcode.hit
			  expect(resp).to be false
  			end
		end


	end

end