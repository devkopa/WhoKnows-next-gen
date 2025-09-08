import { PrismaClient } from '@prisma/client';


const prisma = new PrismaClient();


export const userRepository = {

    async getUserId(usernameReq) {
        return await prisma.users.findUnique({
                where: {
                    username: usernameReq
                },
                select: {
                    id: true
                }
            })
    },

    async addUser(user) {
        return await prisma.users.create({
            data: user,
            select: {
                id: true,
                username: true
            }
        })
    },

    async getUserByUsername(username) {
        return await prisma.users.findUnique({
            where: {
                username: username
            },

            select: {
                id: true,
                username: true,
                password: true
            }
        });
    }

}