import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile_model.dart';
import '../constants/app_constants.dart';

class UserProfileService extends GetxService {
  final supabase = Supabase.instance.client;

  // Check if followers table exists and create test data
  Future<void> ensureFollowersTableExists() async {
    try {
      // Try to query the followers table
      await supabase.from('followers').select('id').limit(1);
      debugPrint('Followers table exists');
    } catch (error) {
      debugPrint('Followers table might not exist: $error');
      // You need to create the table using the SQL file
    }
  }

  // Get user profile by ID
  Future<UserProfileModel?> getUserProfile(String userId) async {
    try {
      debugPrint('Getting user profile for: $userId');
      final response = await supabase
          .from(AppConstants.usersTable)
          .select('*')
          .eq('id', userId)
          .single();

      debugPrint('User profile response: $response');
      return UserProfileModel.fromJson(response);
    } catch (error) {
      debugPrint('Error getting user profile: $error');
      return null;
    }
  }

  // Get user profile by username
  Future<UserProfileModel?> getUserProfileByUsername(String username) async {
    try {
      final response = await supabase
          .from(AppConstants.usersTable)
          .select('*')
          .eq('username', username)
          .single();

      return UserProfileModel.fromJson(response);
    } catch (error) {
      debugPrint('Error getting user profile by username: $error');
      return null;
    }
  }

  // Get follow counts (followers and following)
  Future<Map<String, int>> getFollowCounts(String userId) async {
    try {
      debugPrint('Getting follow counts for user: $userId');
      
      // Get followers count
      final followersResponse = await supabase
          .from('followers')
          .select('id')
          .eq('following_id', userId);

      // Get following count
      final followingResponse = await supabase
          .from('followers')
          .select('id')
          .eq('follower_id', userId);

      final followersCount = (followersResponse as List).length;
      final followingCount = (followingResponse as List).length;
      
      debugPrint('Followers count: $followersCount, Following count: $followingCount');

      return {
        'followers': followersCount,
        'following': followingCount,
      };
    } catch (error) {
      debugPrint('Error getting follow counts: $error');
      return {'followers': 0, 'following': 0};
    }
  }

  // Check if user A follows user B
  Future<bool> isFollowing(String followerId, String followingId) async {
    try {
      final response = await supabase
          .from('followers')
          .select('id')
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .maybeSingle();

      return response != null;
    } catch (error) {
      debugPrint('Error checking follow status: $error');
      return false;
    }
  }

  // Follow a user
  Future<void> followUser(String followerId, String followingId) async {
    try {
      // Check if already following
      final alreadyFollowing = await isFollowing(followerId, followingId);
      if (alreadyFollowing) {
        throw Exception('تتابع هذا المستخدم بالفعل');
      }

      await supabase.from('followers').insert({
        'follower_id': followerId,
        'following_id': followingId,
      });
    } catch (error) {
      debugPrint('Error following user: $error');
      throw Exception('خطأ في متابعة المستخدم: $error');
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(String followerId, String followingId) async {
    try {
      await supabase
          .from('followers')
          .delete()
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
    } catch (error) {
      debugPrint('Error unfollowing user: $error');
      throw Exception('خطأ في إلغاء متابعة المستخدم: $error');
    }
  }

  // Get user's followers
  Future<List<UserProfileModel>> getUserFollowers(String userId) async {
    try {
      final response = await supabase
          .from('followers')
          .select('follower_id, ${AppConstants.usersTable}!followers_follower_id_fkey(*)')
          .eq('following_id', userId);

      return (response as List)
          .map((item) => UserProfileModel.fromJson(item[AppConstants.usersTable]))
          .toList();
    } catch (error) {
      debugPrint('Error getting user followers: $error');
      return [];
    }
  }

  // Get users that a user is following
  Future<List<UserProfileModel>> getUserFollowing(String userId) async {
    try {
      final response = await supabase
          .from('followers')
          .select('following_id, ${AppConstants.usersTable}!followers_following_id_fkey(*)')
          .eq('follower_id', userId);

      return (response as List)
          .map((item) => UserProfileModel.fromJson(item[AppConstants.usersTable]))
          .toList();
    } catch (error) {
      debugPrint('Error getting user following: $error');
      return [];
    }
  }

  // Search users by username or full name
  Future<List<UserProfileModel>> searchUsers(String query) async {
    try {
      final response = await supabase
          .from(AppConstants.usersTable)
          .select('*')
          .or('username.ilike.%$query%,full_name.ilike.%$query%')
          .limit(20);

      return (response as List)
          .map((user) => UserProfileModel.fromJson(user))
          .toList();
    } catch (error) {
      debugPrint('Error searching users: $error');
      return [];
    }
  }

  // Update user profile
  Future<UserProfileModel?> updateUserProfile({
    required String userId,
    String? fullName,
    String? bio,
    String? profileImageUrl,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (fullName != null) updateData['full_name'] = fullName;
      if (bio != null) updateData['bio'] = bio;
      if (profileImageUrl != null) updateData['profile_image_url'] = profileImageUrl;
      
      updateData['updated_at'] = DateTime.now().toIso8601String();

      final response = await supabase
          .from(AppConstants.usersTable)
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return UserProfileModel.fromJson(response);
    } catch (error) {
      debugPrint('Error updating user profile: $error');
      throw Exception('خطأ في تحديث الملف الشخصي: $error');
    }
  }
}