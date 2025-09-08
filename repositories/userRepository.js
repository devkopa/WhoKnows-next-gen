import { PrismaClient } from '@prisma/client';


const prisma = new PrismaClient();


export const userRepository = {

    async getUserId(usernameReq) {
        if (typeof usernameReq === "string") {
            return await prisma.users.findUnique({
                where: {
                    username: usernameReq
                },
                select: {
                    id: true
                }
            })
        }
    }

}