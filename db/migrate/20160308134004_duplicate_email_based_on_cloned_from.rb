class DuplicateEmailBasedOnClonedFrom < ActiveRecord::Migration
  def change
    reversible do |dir|
      cloned_people = select_all("
        SELECT id, cloned_from FROM people WHERE cloned_from IS NOT NULL
      ").to_ary

      dir.up do
        cloned_people.each do |p|
          execute("
              INSERT INTO
              emails
               (person_id, address, confirmed_at, confirmation_sent_at, confirmation_token, created_at, updated_at, send_notifications)
              (SELECT
               #{quote(p['id'])}, address, confirmed_at, confirmation_sent_at, confirmation_token, created_at, updated_at, send_notifications
               FROM emails WHERE person_id = #{quote(p['cloned_from'])})
               ")
        end
      end

      dir.down do
        execute("
          DELETE emails
          FROM emails, people
          WHERE
            emails.person_id = people.id AND
            people.cloned_from IS NOT NULL
          ")
      end
    end
  end
end
