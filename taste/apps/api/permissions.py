from rest_framework.permissions import BasePermission, SAFE_METHODS


class IsOwnObjectOrReadOnly(BasePermission):
    """
    The request is authenticated as a user who created the object in question,
    or is a read-only request.
    """

    def has_permission(self, request, view, obj=None):
        if (request.method in SAFE_METHODS or
            not obj or
            request.user and
            request.user.is_authenticated() and
            request.user == obj.user):
            return True
        return False
