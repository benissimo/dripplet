require 'csv-mapper'
require 'factory_girl' #1.2.4
require 'faker' #0.3.1

#config.action_mailer.delivery_method = :test
ActionMailer::Base.delivery_method = :test
ActionMailer::Base.perform_deliveries = false

class AddBatchDripplets

  include CsvMapper

  # Parse a yaml file containing list of dripplets (water_points) to be created.
  # For each dripplet,
  ## If no user or if user's dripplet count > user_wp_max, create new user
  ### new user should be fully registered, using noreply@madeintomorrow.com as email address
  ### Ensure email notification is off while this script runs.
  # Then validate dripplet data. If contains URL of photo, download photo and add as wp photo
  # If valid dripplet, save.


  # Verify:
  ## yaml file parsable OK.
  ## users look "real". use populator or equivalent gem...
  ## no emails get sent out during user creation.
  ## dry-run: check user and wp count.
  ## photo download/upload OK. dry-run: raise exception if photo too large, unreachable, etc.


  # ways to import data:
  ## looping over data, create one row at a time.
  ## batch insert via activerecord-extension gem (faster, safer)
  ### but: problems with batch insert:
  #### 1) in cases where I need to do geocode lookup, can't efficiently ask that of google maps. easier to do one at a time.
  #### 2) in cases where I need to download and upload a photo for the wp, need to do that one at a time.


  # simplify user/wp association:
  ## count how many wp there are to import
  ### divide by user_wp_max, round up. create that number of users, keep track of the IDs of each created user
  ### then for each wp I add, choose randomly from the created IDs.
  ### this way you first create users, then create wp. hmm, but downside is, any problems, I have a bunch of empty users.
  ### that's OK, after wp creation, mark them as activated. leave them unactivated during import.

  # http://www.igvita.com/2007/07/11/efficient-updates-data-import-in-rails/


  # consider modifying models/db to simplify import:
  ## User --> add field and index on "batch_id". Makes it easier to do cleanup if necessary.
  ## Waterpoint --> add field and index on "batch_id", default = nil. Again, helps identify what came from batch, and which batch.
  ## Waterpoint --> add field and index on "state". default = "active", makes it easy to delete without removing data.
  ## Waterpoint --> add field "photo_url". default = nil. If defined, point directly at remote photo. Resize via html...
  ### Risky if remote photo gets moved/deleted. But simplifies batch and saves disk space.

  @@user = nil
  @@batch_id = nil
  @@wp_count = 0
  @@user_count = 0


  def run

    unless ARGV[0] and File.file?(ARGV[0])
      puts "indicate which CSV to load."
      return
    end

    @csv_file = ARGV[0]
    @@batch_id = File.basename(ARGV[0], ".csv")

    puts "opening csv file #{@csv_file}."

    # Using csv-mapper
    results = import(@csv_file) do
      map_to WaterPoint

      after_row lambda{|row, wp|

        wp.batch_id = AddBatchDripplets.get_batch_id #@batch_id
        wp.posted_by = AddBatchDripplets.get_user
        # wp.addr = "Via dei Marsi 9, Roma, Italia" #assigning to addr triggers geocode lookup
        wp.note ||= '' #no nil for batch. '' is shorter than null in js. saves space...

        wp.confirmed = true
        wp.save and AddBatchDripplets.add_wp_count
      }

      start_at_row 1
      [lat, lng, title, note, photo_url, addr]
    end

    #report
    puts "Looped over #{results.count} results"
    puts "#{@@wp_count} dripplets imported for #{@@user_count} users."
  end

  def self.user_wp_max
    10
  end

  def self.get_user
    if (@@user.nil? or (@@user.water_points_count > self.user_wp_max))
      @@user = _new_user
      self.add_user_count
    end
    puts "User has #{@@user.water_points_count} wp compared to max of #{self.user_wp_max}"
    @@user
  end

  def self._new_user
    # generate users with realistic looking names.
    # this is just a stub. need to generate these not randomly but rather using a set of canned data.
    @@user = Factory(:user)
    puts "new user with login #{@@user.login}"
    #rand_id = rand(User.count)
    #@@user = User.first(:conditions => ["id >= ?", rand_id])
    @@user.activate!
    @@user
  end

  def self.get_batch_id
    @@batch_id
  end

  def self.add_wp_count
    @@wp_count += 1
  end

  def self.add_user_count
    @@user_count += 1
  end

  def self.undo
    puts "deleting"
    #@@batch_id = nil
    unless @@batch_id
      puts "Batch id to delete? (type carefully)"
      @@batch_id = $stdin.gets.chomp
    end
    if @@batch_id && @@batch_id.length > 1
      puts WaterPoint.delete_all(["batch_id = ?", @@batch_id])
      puts User.delete_all(["batch_id = ?", @@batch_id])
    else
      puts "no batch_id to undo. skipping delete."
    end
  end

end


Factory.define :user do |u|
  u.login {
    not_found = true
    while not_found do
      f = Faker::Internet.user_name
      unless User.find_by_login(f)
        not_found = false
      end
    end
    f
    }
  u.email {
    not_found = true
    while not_found do
      f = Faker::Internet.email
      unless User.find_by_email(f)
        not_found = false
      end
    end
    f
    }
  u.password { AddBatchDripplets.get_batch_id }
  u.password_confirmation { AddBatchDripplets.get_batch_id }
  u.locale 'it'
  u.first_ip '127.0.0.1'
  u.last_ip '127.0.0.1'
  u.batch_id { AddBatchDripplets.get_batch_id }
end

a = AddBatchDripplets.new
a.run
#AddBatchDripplets.undo



