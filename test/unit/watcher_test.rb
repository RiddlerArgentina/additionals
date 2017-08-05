require File.expand_path('../../test_helper', __FILE__)

class WatcherTest < ActiveSupport::TestCase
  fixtures :projects, :users, :email_addresses, :members, :member_roles, :roles, :enabled_modules,
           :issues, :issue_statuses, :enumerations, :trackers, :projects_trackers,
           :boards, :messages,
           :wikis, :wiki_pages,
           :watchers

  def setup
    @author = User.find(1)
    @assigned_user = User.find(2)
    @changing_user = User.find(4)
  end

  def test_new_issue_with_author_watch_only
    User.current = @author
    issue = Issue.generate(author_id: @author.id)
    issue.save
    assert_equal 1, issue.watchers.count
    assert issue.watched_by?(@author)
  end

  def test_new_issue_with_author_and_assigned_to_watchers
    User.current = @author
    issue = Issue.generate(author_id: @author.id, assigned_to: @assigned_user)
    issue.save

    assert_equal 2, issue.watchers.count
    assert issue.watched_by?(@author)
    assert issue.watched_by?(@assigned_user)
  end

  def test_issue_do_not_add_author_with_user_change
    User.current = @author

    issue = Issue.generate(author_id: @author.id, assigned_to: @assigned_user)
    issue.save
    assert_equal 2, issue.watchers.count

    issue.remove_watcher(@author)
    issue.reload
    assert_equal 1, issue.watchers.count

    User.current = @changing_user
    issue.subject = 'Changing....'
    issue.save

    assert_equal 2, issue.watchers.count
    assert issue.watched_by?(@changing_user)
    assert issue.watched_by?(@assigned_user)
  end

  def test_issue_do_not_add_assigned_to_with_user_change
    User.current = @author

    issue = Issue.generate(author_id: @author.id, assigned_to: @assigned_user)
    issue.save
    assert_equal 2, issue.watchers.count

    issue.remove_watcher(@assigned_user)
    issue.reload
    assert_equal 1, issue.watchers.count

    User.current = @changing_user
    issue.subject = 'Changing....'
    issue.save

    assert_equal 2, issue.watchers.count
    assert issue.watched_by?(@author)
    assert issue.watched_by?(@changing_user)
  end
end