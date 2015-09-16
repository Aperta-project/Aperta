class RemovePlosAuthors < ActiveRecord::Migration
  def up

    # migrate `plos_authors` data to `authors`
    attribute_sql = %Q{
      UPDATE authors
      SET
        middle_initial        = plos_authors.middle_initial,
        email                 = plos_authors.email,
        department            = plos_authors.department,
        title                 = plos_authors.title,
        corresponding         = plos_authors.corresponding,
        deceased              = plos_authors.deceased,
        affiliation           = plos_authors.affiliation,
        secondary_affiliation = plos_authors.secondary_affiliation,
        contributions         = plos_authors.contributions,
        ringgold_id           = plos_authors.ringgold_id,
        secondary_ringgold_id = plos_authors.secondary_ringgold_id
      FROM plos_authors_plos_authors as plos_authors
      WHERE plos_authors.id = authors.actable_id;
    }
    ActiveRecord::Base.connection.execute(attribute_sql)

    # update existing tasks to new model name
    task_sql = %Q{
      UPDATE tasks
      SET type = 'TahiStandardTasks::AuthorsTask'
      WHERE type = 'PlosAuthors::PlosAuthorsTask'
    }
    ActiveRecord::Base.connection.execute(task_sql)
  end

  def down
    # noop
  end
end
