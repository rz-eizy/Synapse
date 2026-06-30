export type ModerationStatus = 'pending' | 'approved' | 'rejected'
export type AccountStatus = 'active' | 'suspended' | 'banned' | 'under_review'
export type UserType = 'community' | 'professional'

export interface User {
  id: string
  username: string
  displayName: string
  avatar?: string
  type: UserType
  verified: boolean
  followersCount: number
  joinedAt: string
  status: AccountStatus
  email: string
  reportsCount: number
}

export interface PostImage {
  id: string
  url: string
  alt?: string
}

export interface ReportDetail {
  id: string;
  type: string;
  description: string;
  createdAt: string;
  reporterUsername: string;
  resolved: boolean;
}

export interface Post {
  id: string
  author: User
  content: string
  images?: PostImage[]
  likesCount: number
  commentsCount: number
  reportsCount: number
  reports?: ReportDetail[]
  status: ModerationStatus
  createdAt: string
  tags?: string[]
  type: UserType
}

export interface Comment {
  id: string
  author: User
  postId: string
  postPreview: string
  content: string
  likesCount: number
  reportsCount: number
  reports?: ReportDetail[]
  status: ModerationStatus
  createdAt: string
}

export interface Account {
  id: string
  user: User
  postsCount: number
  reportedPostsCount: number
  reportedCommentsCount: number
  status: AccountStatus
  createdAt: string
  lastActiveAt: string
  bio?: string
}

export interface DashboardStats {
  pendingPosts: number
  pendingComments: number
  pendingAccounts: number
  resolvedToday: number
  totalReports: number
  approvalRate: number
}