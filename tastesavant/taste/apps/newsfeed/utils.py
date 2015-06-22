from taste.apps.newsfeed.models import Activity, Action

def store_activity(user, action_name, metadata=None, occurred=None):
    action=Action.objects.get(action_name=action_name)
    Activity.objects.create(user=user, action=action, meta_data=metadata,
                            occurred=occurred)
